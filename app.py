from flask import Flask, render_template, Response, request, jsonify, send_file
from flask_caching import Cache
import datetime, hmac, hashlib, subprocess, os, time, threading, pymysql
from dotenv import load_dotenv


load_dotenv()
app = Flask(__name__)


GITHUB_SECRET = os.getenv('GITHUB_SECRET').encode()
SUDO_PASSWORD = os.getenv('SUDO_PASSWORD')
host = os.environ.get("DB_HOST")
user = os.environ.get("DBUSER")
passwd = os.environ.get("DBPW")
db = os.environ.get("DB_NAME")
dir = os.environ.get("OUTPUT_DIR")
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


@app.route('/domain-scout')
def domain_scout():
    return render_template('domain-scout.html')


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


### Domain Scout App
def connect_to_database(host=host, user=user, passwd=passwd, db=db):
    db_connection = pymysql.connect(host=host, user=user, password=passwd, database=db, cursorclass=pymysql.cursors.DictCursor)
    print("Connected to SQL database")
    return db_connection


def execute_query(db_connection=None, query=None, query_params=()):
    cursor = db_connection.cursor()
    cursor.execute(query, query_params)
    db_connection.commit()
    return cursor


@app.route('/DomainScout')
def domainScout():
    db_connection = connect_to_database()
    query = "SELECT COUNT(*) AS total_records FROM domains_data;"
    cursor = execute_query(db_connection=db_connection, query=query)
    result = cursor.fetchone()
    total_records = result['total_records']
    db_connection.close()
    return render_template('domainScout.html', total_records=total_records)


@app.route('/DomainScout/api', methods=['GET'])
def fetch_records():
    db_connection = connect_to_database()
    query = "SELECT * FROM domains_data;"
    cursor = execute_query(db_connection=db_connection, query=query)
    records = cursor.fetchall()
    db_connection.close()
    return jsonify(records)


@app.route('/DomainScout/api/delete', methods=['DELETE'])
def delete_record():
    domain = request.args.get('domain')
    if not domain:
        return jsonify({'error': 'Domain parameter is required'}), 400
    db_connection = connect_to_database()
    try:
        query = "DELETE FROM domains_data WHERE domain = %s;"
        execute_query(db_connection=db_connection, query=query, query_params=(domain,))
        return jsonify({'message': f'Records for domain {domain} deleted successfully'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        db_connection.close()


@app.route('/DomainScout/api/save', methods=['POST'])
def save_record():
    records = request.get_json()

    for record in records:

        domain = record.get('domain')
        admin_email = record.get('admin_email')
        registrar = record.get('registrar')
        tech_email = record.get('tech_email')
        registrant_email = record.get('registrant_email')
        creation_date = record.get('creation_date')
        expiration_date = record.get('expiration_date')
        updated_date = record.get('updated_date')
        emails = record.get('emails')

        if not domain or not admin_email or not registrar:
            return jsonify({'error': 'Missing required fields'}), 400

        db_connection = connect_to_database()
        query = """
        INSERT INTO domains_data (domain, admin_email, registrar, tech_email, registrant_email, 
                                  creation_date, expiration_date, updated_date, emails)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s);
        """
        query_params = (domain, admin_email, registrar, tech_email, registrant_email, 
                        creation_date, expiration_date, updated_date, emails)
        
        execute_query(db_connection=db_connection, query=query, query_params=query_params)
        db_connection.close()
        
        return jsonify({'message': 'Record saved successfully'}), 200
    
    
def generate_sql_dump():
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    dump_file_name = f"{db}_export_{timestamp}.sql"
    dump_file_path = os.path.join(dir, dump_file_name)

    mysqldump_command = [
        "mysqldump",
        "-u", user,
        "-p" + passwd,  # No space between -p and password
        "-h", host,
        db,
        "--result-file=" + dump_file_path
    ]

    try:
        subprocess.run(mysqldump_command, check=True)
        return dump_file_path
    except subprocess.CalledProcessError as e:
        print(f"Error creating SQL dump: {e}")
        return None
    
@app.route('/DomainScout/api/export-dump', methods=['GET'])
def export_sql_dump():
    dump_file_path = generate_sql_dump()

    if dump_file_path:
        return send_file(dump_file_path, as_attachment=True)
    else:
        return jsonify({"error": "Failed to generate the database dump."}), 500
    
@app.route('/DomainScout/api/import-dump', methods=['POST'])
def import_sql_dump():
    file = request.files['file']
    importDir = os.path.join(dir, 'SQL-uploads')
    os.makedirs(importDir, exist_ok= True)
    import_file_path = os.path.join(importDir, file.filename)
    file.save(import_file_path)
    
    try:
        mysqlimport_command = f"mysql -u {user} -p{passwd} -h {host} {db} -e 'SOURCE {import_file_path}'"
        subprocess.run(mysqlimport_command, shell=True, check=True)
        os.remove(import_file_path)

        return jsonify({'message': 'SQL dump imported successfully'}), 200

    except subprocess.CalledProcessError as e:
        return jsonify({'error': 'Failed to import SQL dump'}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8050, debug=False) 