!#/bin/bash

sudo docker pull splunk/splunk:latest

sudo docker run -d -p 8000:8000 -e SPLUNK_GENERAL_TERMS="--accept-sgt-current-at-splunk-com" -e SPLUNK_START_ARGS="--accept-license" -e SPLUNK_PASSWORD="changeme123" --name splunk-server splunk/splunk:latest

# Should say "healthy" and not "heath:starting" before proceeding
sudo docker ps

# Access Splunk via web browser at http://localhost:8000

# Login with username: admin and password: changeme123

# Enable listening on port 9997 to receive data from forwarder. May already be set
sudo docker exec -u splunk splunk-server /opt/splunk/bin/splunk enable listen 9997 -auth admin:changeme123