import threading
from flask import Flask, render_template, jsonify, request, send_file
import pymysql
import whois
import websocket
import asyncio
import json
import subprocess
import time
import os
import re
from datetime import datetime
import pymysql
from dotenv import load_dotenv, find_dotenv

app = Flask(__name__)

load_dotenv(find_dotenv())

host = os.environ.get("DB_HOST")
user = os.environ.get("DB_USER")
passwd = os.environ.get("DB_PASSWD")
db = os.environ.get("DB_NAME")
dir = os.environ.get("OUTPUT_DIR")

def connect_to_database(host=host, user=user, passwd=passwd, db=db):
    db_connection = pymysql.connect(host=host, user=user, password=passwd, database=db, cursorclass=pymysql.cursors.DictCursor)
    print("Connected to SQL database")
    return db_connection

def execute_query(db_connection=None, query=None, query_params=()):
    cursor = db_connection.cursor()
    cursor.execute(query, query_params)
    db_connection.commit()
    return cursor

@app.route('/')
def home():
    db_connection = connect_to_database()
    query = "SELECT COUNT(*) AS total_records FROM domains_data;"
    cursor = execute_query(db_connection=db_connection, query=query)
    result = cursor.fetchone()
    total_records = result['total_records']
    db_connection.close()
    return render_template('index.html', total_records=total_records)

@app.route('/api', methods=['GET'])
def fetch_records():
    db_connection = connect_to_database()
    query = "SELECT * FROM domains_data;"
    cursor = execute_query(db_connection=db_connection, query=query)
    records = cursor.fetchall()
    db_connection.close()
    return jsonify(records)

@app.route('/api/delete', methods=['DELETE'])
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

@app.route('/api/save', methods=['POST'])
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

@app.route('/api/export-dump', methods=['GET'])
def export_sql_dump():
    dump_file_path = generate_sql_dump()

    if dump_file_path:
        return send_file(dump_file_path, as_attachment=True)
    else:
        return jsonify({"error": "Failed to generate the database dump."}), 500

@app.route('/api/import-dump', methods=['POST'])
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
    app.run(host='0.0.0.0', port=5000, debug=False)
