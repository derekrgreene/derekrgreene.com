from flask import Flask, render_template, Response, request, jsonify, session
from flask_caching import Cache
import datetime, hmac, hashlib, subprocess, os, time, threading, shlex
from dotenv import load_dotenv

load_dotenv()
app = Flask(__name__)


GITHUB_SECRET = os.getenv('GITHUB_SECRET').encode()
SUDO_PASSWORD = os.getenv('SUDO_PASSWORD')
app.secret_key = os.urandom(24)
SAFE_DIR = "/home/derek/Desktop/web/"
app.config['CACHE_TYPE'] = 'simple'
cache = Cache(app)


@app.errorhandler(404)
def notFound(error):
    return render_template('404.html'), 404


@app.errorhandler(500)
def internalError(error):
    return render_template('500.html'), 500


@app.route('/')
@cache.cached(timeout=3600) # 1 hour
def index():      
    return render_template('index.html')


@app.route('/DCV-Dependencies')
def DCVDependencies():
    return render_template('dv.html')


@app.route('/domainScout')
def domainScout():
    return render_template('domainscout.html')


@app.route('/gardenPlanter')
def gardenPlanter():
    return render_template('gardenplanter.html')


@app.route('/inventoryTracker')
def inventoryTracker():
    return render_template('inventorytracker.html')


@app.route('/lowLevelIO')
def lowLevelIO():
    return render_template('lowlevelio.html')


@app.route('/OTP')
def OTP():
    return render_template('otp.html')


@app.route('/randomNumGen')
def randomNumGen():
    return render_template('randomnumgen.html')


@app.route('/smallSH')
def smallSH():
    return render_template('smallsh.html')


@app.route('/snakeGame')
def snakeGame():
    return render_template('snakegame.html')


@app.route('/virtualPantry')
def virtualPantry():
    return render_template('virtualpantry.html')


@app.route("/pgp")
def pgp():
    with open("pgp.asc", "r") as keyfile:
        keydata = keyfile.read()
    return Response(keydata, mimetype="text/plain")


@app.route('/robots.txt')
def robots():
    return Response("User-agent: *\nAllow: /\nSitemap: https://derekrgreene.com/sitemap.xml",mimetype="text/plain")


@app.route('/sitemap.xml')
def sitemap():
    baseUrl = "https://derekrgreene.com"
    today = datetime.datetime.now().strftime('%Y-%m-%d')
    
    urls = [
        {"loc": f"{baseUrl}/", "priority": "1.0"},
        {"loc": f"{baseUrl}/domainScout", "priority": "0.8"},
        {"loc": f"{baseUrl}/OTP", "priority": "0.8"},
        {"loc": f"{baseUrl}/inventoryTracker", "priority": "0.8"},
        {"loc": f"{baseUrl}/snakeGame", "priority": "0.8"},
        {"loc": f"{baseUrl}/virtualPantry", "priority": "0.8"},
        {"loc": f"{baseUrl}/gardenPlanter", "priority": "0.8"},
        {"loc": f"{baseUrl}/smallSH", "priority": "0.8"},
        {"loc": f"{baseUrl}/lowLevelIO", "priority": "0.8"},
        {"loc": f"{baseUrl}/randomNumGen", "priority": "0.8"},
        {"loc": f"{baseUrl}/DCV-Dependencies", "priority": "0.9"},
    ]
    
    xml_content = '<?xml version="1.0" encoding="UTF-8"?>\n'
    xml_content += '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'
    
    for url in urls:
        xml_content += '  <url>\n'
        xml_content += f'    <loc>{url["loc"]}</loc>\n'
        xml_content += f'    <lastmod>{today}</lastmod>\n'
        xml_content += '    <changefreq>monthly</changefreq>\n'
        xml_content += f'    <priority>{url["priority"]}</priority>\n'
        xml_content += '  </url>\n'
    xml_content += '</urlset>'
    
    return Response(xml_content, mimetype='application/xml')


def verify_signature(payload, signature):
    expected_mac = hmac.new(GITHUB_SECRET, payload, hashlib.sha256).hexdigest()
    expected_signature = f"sha256={expected_mac}"
    return hmac.compare_digest(expected_signature, signature)


@app.route("/deploy", methods=["POST"])
def deploy():
    signature = request.headers.get("X-Hub-Signature-256")
    if not signature or not verify_signature(request.data, signature):
        return "Invalid signature", 403
    
    subprocess.run("source venv/bin/activate && pip install -r requirements.txt && git pull", shell=True, check=True, cwd="/var/www/derekrgreene.com", executable="/bin/bash", stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    threading.Thread(target=delayed_service_restart, daemon=True).start()
    return "Deployment successful!", 200


def delayed_service_restart():
    time.sleep(30)
    subprocess.run(f"echo {SUDO_PASSWORD} | sudo -S systemctl restart derekrgreene.com.service", shell=True, check=True)


def is_within_safe_dir(path):
    """Check if the given path is within the safe directory."""
    absolute_path = os.path.abspath(path)
    return os.path.commonpath([absolute_path, os.path.abspath(SAFE_DIR)]) == os.path.abspath(SAFE_DIR)


@app.route('/run_command', methods=['POST'])
def run_command():
    data = request.get_json()
    command = data.get('command')

    if 'current_dir' not in session:
        session['current_dir'] = SAFE_DIR

    current_dir = session['current_dir']
    os.chdir(current_dir)

    try:
        if command.startswith("cd "):
            target_dir = command.split(" ", 1)[1]
            new_dir = os.path.join(current_dir, target_dir)
            if is_within_safe_dir(new_dir) and os.path.isdir(new_dir):
                session['current_dir'] = new_dir
                os.chdir(new_dir)
                output = ""
            else:
                output = "You are not authorized access to files outside of this web app's directory!"
        else:
            parts = shlex.split(command)
            base_command = parts[0]
            
            if base_command in ["ls", "pwd", "date", "echo", "cat"]:
                if base_command == "cat" and len(parts) > 1:
                    file_path = parts[1]
                    if not os.path.isabs(file_path):
                        file_path = os.path.join(current_dir, file_path)
                    
                    if not is_within_safe_dir(file_path):
                        output = "You are not authorized to access files outside of this web app's directory!"
                    else:
                        result = subprocess.run(command, shell=True, capture_output=True, text=True, cwd=current_dir)
                        output = result.stdout if result.returncode == 0 else result.stderr
                else:
                    result = subprocess.run(command, shell=True, capture_output=True, text=True, cwd=current_dir)
                    output = result.stdout if result.returncode == 0 else result.stderr
            else:
                output = "Command not recognized or not allowed."

    except Exception as e:
        output = f"Error: {str(e)}"

    return jsonify({'output': output, 'new_dir': session['current_dir']})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8050, debug=False) 