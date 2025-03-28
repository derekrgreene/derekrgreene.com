from flask import Flask, render_template, Response, request
from flask_caching import Cache
import datetime, hmac, hashlib, subprocess, os
from dotenv import load_dotenv




load_dotenv()
app = Flask(__name__)


GITHUB_SECRET = os.getenv(b'GITHUB_SECRET')
SUDO_PASSWORD = os.getenv('SUDO_PASSWORD')
app.config['CACHE_TYPE'] = 'simple'
cache = Cache(app)


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
    subprocess.run(f"echo {SUDO_PASSWORD} | sudo -S systemctl restart derekrgreene.com.service", shell=True, check=True)
    return "Deployment successful!", 200








  
    
    
    
    
    

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


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8050, debug=True) 