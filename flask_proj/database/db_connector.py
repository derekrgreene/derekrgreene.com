# Authors: Derek Greene & Nathan Schuler
# Date: 7/2024
# Course: CS340 - Introduction to Databases
# Citation for db_connector.py:
# Adapted to utilize pymysql instead of MySQLdb and removed unnecessary functions/sample query
# Source URL: https://github.com/osu-cs340-ecampus/flask-starter-app/blob/master/database/db_connector.py

import pymysql
import os
from dotenv import load_dotenv, find_dotenv

# Load environment variables from .env file
load_dotenv(find_dotenv())

# Get db credentials from environment variables
if os.getenv("DOCKER_ENV"):   # Check if running in Docker 
    host = os.getenv("DBHOST", "db")  # Use Docker service name
else:
    host = os.getenv("DBHOST", "localhost")  # Use localhost for normal deployment
user = os.environ.get("DBUSER")
passwd = os.environ.get("DBPW")
db = os.environ.get("DB")

# Function to connect to the database using pymysql
def connect_to_database(host=host, user=user, passwd=passwd, db=db):
    db_connection = pymysql.connect(host=host, user=user, password=passwd, database=db, 
cursorclass=pymysql.cursors.DictCursor)
    return db_connection

# Function to execute a query on the database
def execute_query(db_connection=None, query=None, query_params=()):
    cursor = db_connection.cursor()
    cursor.execute(query, query_params)
    db_connection.commit()
    return cursor