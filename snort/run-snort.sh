#!/bin/bash

$SPLUNK_HOME/bin/splunk enable listen 9997 -auth admin:password

sudo -u splunk $SPLUNK_HOME/bin/splunk start --accept-license

# Create log directory if it doesn't exist
mkdir -p /var/log/snort

# Append custom rules to local.rules
cat /etc/snort/rules/devops.rules >> /etc/snort/rules/local.rules

# Run Snort on eth0 interface
snort -c /etc/snort/snort.conf \
	-i eth0 \
	-A console \
	-l /var/log/snort \
	-K ascii 