# Create Your Own Snort Docker Container (Optional)

*This section is optional. We provide this Docker image for you to use directly with Terraform. Skip ahead to the Terraform tutorials if you prefer to use the pre-built images.*

This tutorial will guide you through the setup of Snort, with a simple rule for detecting ICMP traffic and writing alerts to a log direcory. We will create a basic HTTP server that serves that files inside the log directory to clients. These logs can then be used by administrators or analysts for log analysis to detect potential security incidents.

## Prerequisites
 - Docker installed on your machine

## Create Custom Snort Rules and Run Script
- Create a directory called snort and navigate into it:
```bash
mkdir snort
cd snort
```
- Create any custom rules you want to use in a file called `devops.rules`. For this tutorial we will use a simple rule that detects ICMP traffic and logs it to the alert file. Create the file and open it with nano:
```bash
nano devops.rules
```
- Add the following rule to the file. The rules should be written one per line:
```bash
alert icmp any any -> any any (msg:"ICMP echo request detected!"; itype:8; sid:10000001;)
```
- Close the editor by pressing `ctrl + S`and `ctrl + X` to save and exit.
- Now we will create the script that runs on container start. This script will start Snort with the appropriate command line arguments to read the custom rules and log alerts to our monitoring directory. It will also start the HTTP server to serve the log files. Create `run-snort.sh` and open it with nano:
```bash
nano run-snort.sh
```
- Add the following lines to the file:
```bash
#!/bin/bash

# Append custom rules to local.rules
cat /etc/snort/rules/devops.rules >> /etc/snort/rules/local.rules

# Create log directory if it doesn't exist
mkdir -p /var/log/snort

# Navigate to log directory and start a simple HTTP server to serve log files in the background
cd /var/log/snort
python3 -m http.server 8080 &

# Run Snort on eth0 interface (standard inside Docker containers)
snort -c /etc/snort/snort.conf \
	-i eth0 \
	-A console \
	-l /var/log/snort/ \
	-q \
	-K ascii
```
- Close the editor by pressing `ctrl + S`and `ctrl + X` to save and exit.

## Create Dockerfile
- Create a file called `Dockerfile` and open it with nano
```bash
nano Dockerfile
```
- We will now create a small containerized environment with the required packages to run the Snort instance. Add the following lines to the Dockerfile:
```Dockerfile
FROM ubuntu:latest

RUN apt-get update && \
	apt-get install -y snort \
	iputils-ping \
	python3

# Copy custom rules and run script into the container and make the script executable
COPY devops.rules /etc/snort/rules/
COPY run-snort.sh /etc/snort/
RUN chmod +x /etc/snort/run-snort.sh

# Expose port for HTTP server serving log files
EXPOSE 8080

ENTRYPOINT ["/etc/snort/run-snort.sh"]
```
- Close the editor by pressing `ctrl + S`and `ctrl + X` to save and exit.

## Build the Image
- Inside the `snort` directory, build the Docker image with the following command. This will download the required base image, dependencies, and create a new image called `snort`:
```bash
systemctl start docker
docker build -t snort .
```
- After the build completes, you can verify that the image was created successfully by running:
```bash
docker images
```
- You should see an image named `snort` in the list.

## What We Have Done
- We successfully created a Snort instance that logs custom alerts.
- We built the image and prepared it for use by Terraform in later steps of this tutorial.