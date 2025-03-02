#!/bin/bash

# Log file for output
LOGFILE="/var/www/derekrgreene.com/certstream-server-go/startup.log"

# Check if the Docker container is already running
if ! docker ps | grep -q "0rickyy0/certstream-server-go"; then
  echo "Starting Docker..." | tee -a $LOGFILE
  docker run -d -p 8080:8080 0rickyy0/certstream-server-go:latest >> $LOGFILE 2>&1
  if [ $? -eq 0 ]; then
    echo "Docker container started successfully" | tee -a $LOGFILE
  else
    echo "Failed to start Docker container" | tee -a $LOGFILE
    exit 1
  fi
else
  echo "Docker container already running" | tee -a $LOGFILE
fi

# Activate the Python virtual environment
echo "Activating Python VENV..." | tee -a $LOGFILE
source /var/www/derekrgreene.com/certstream-server-go/venv/bin/activate
if [ $? -eq 0 ]; then
  echo "VENV activated" | tee -a $LOGFILE
else
  echo "Failed to activate VENV" | tee -a $LOGFILE
  exit 1
fi

# Start Flask App in the background
echo "Starting Flask App..." | tee -a $LOGFILE
python3 /var/www/derekrgreene.com/certstream-server-go/app.py &

# Start WebSocket in the background
echo "Starting WebSocket..." | tee -a $LOGFILE
python3 /var/www/derekrgreene.com/certstream-server-go/websocket.py &

# Start domains.py in the background
echo "Starting domains.py..." | tee -a $LOGFILE
python3 /var/www/derekrgreene.com/certstream-server-go/domains.py &

# Wait for all background processes to start
wait

echo "All services started" | tee -a $LOGFILE

# Keep the script alive (prevents it from exiting)
while true; do
  sleep 3600  # Sleep for an hour to keep the script alive
done
