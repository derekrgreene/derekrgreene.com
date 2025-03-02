#!/bin/bash

mysql -u derek -pW0rthit? -e "USE cs340; SOURCE /var/www/derekrgreene.com/flask_proj/database/es_db.sql;"

