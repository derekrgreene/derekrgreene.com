#!/bin/bash

mysql -e "USE cs340; SOURCE /var/www/derekrgreene.com/flask_proj/database/es_db.sql;"

