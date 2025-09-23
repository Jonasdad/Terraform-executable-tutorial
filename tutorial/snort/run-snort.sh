#!/bin/bash

# Append custom rules to local.rules
cat /etc/snort/rules/devops.rules >> /etc/snort/rules/local.rules

# Create log directory if it doesn't exist
mkdir -p /var/log/snort

cd /var/log/snort
python3 -m http.server 8080 &

# Run Snort on eth0 interface
snort -c /etc/snort/snort.conf \
	-i eth0 \
	-A console \
	-l /var/log/snort/ \
	-q \
	-K ascii