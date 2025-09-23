# Create Your Own HTTP Server (Optional)

This tutorial will guide you through creating an HTTP server that polls the Snort container for alerts. The alert logs will be downloaded and printed to the terminal inside the container. This will simulate a SIEM software that aggregate potential network incidents allowing for network monitoring.

## Prerequisites
 - Docker installed on your machine

## Create Dockerfile and run.sh Script
- Create a directory called http and navigate into it:
```bash
mkdir http
cd http
```
- Create a file called Dockerfile and open it with nano
```bash
nano Dockerfile
```
- We will now create a small containerized environment with the required packages to run the polling service. Add the following lines to the Dockerfile:
```Dockerfile
FROM python:3.9-slim

# Install curl for HTTP requests
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Copy the run script
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Run the server
ENTRYPOINT [ "/usr/local/bin/run.sh" ]
```
- Close the editor by pressing `ctrl + S`and `ctrl + X` to save and exit.
- The `run.sh` script will contain the logic to poll the Snort container for alerts. The file is copied into the container when building it and runs when the container starts. Create the `run.sh` file in the same directory and open it with nano:
```bash
nano run.sh
```
- Add the following code to the `run.sh` file. The purpose of this tutorial is not to create a HTTP server, and the code will not be explained in detail. In short, the script will poll the Snort container every 30 seconds and download any log files found in the `/var/log/snort` directory inside the Snort instance. The logs will be printed to the terminal inside the container:
```bash
#!/bin/bash

get_logs() {
    while true; do
        echo "Polling for logs..."
        sleep 30
        
		# Get logs from Snort container HTTP server (serving /var/log/snort directory)
        
		# First check main directory for any files
        curl -s "http://172.18.0.3:8080/" 2>/dev/null | grep -o 'href="[^"]*"' | sed 's/href="//;s/"//' | grep -v "^/$" | while read -r item; do
            if [[ "$item" == */ ]]; then
                # It's a directory, check for files inside
                echo "Checking directory: $item"
                curl -s "http://172.18.0.3:8080/$item" 2>/dev/null | grep -o 'href="[^"]*"' | sed 's/href="//;s/"//' | grep -v "^/$" | while read -r logfile; do
                    if [[ "$logfile" != */ ]]; then
                        echo "Found log file: $item$logfile"
                        
						# Get file size from HTTP HEAD request
                        filesize=$(curl -sI "http://172.18.0.3:8080/$item$logfile" | grep -i content-length | awk '{print $2}' | tr -d '\r' || echo "unknown")
                        echo "===== Log file: $logfile (Size: ${filesize} bytes) ====="
                        
						# Download and print the actual log content
                        curl -s "http://172.18.0.3:8080/$item$logfile" 2>/dev/null
                        echo "===== End of $logfile ====="
                        echo ""
                    fi
                done
            else
                # It's a file in the main directory
                logfile="$item"
                if [ -n "$logfile" ]; then
                echo "Found log file: $logfile"
                
				# Get file size from HTTP HEAD request
                filesize=$(curl -sI "http://172.18.0.3:8080/$logfile" | grep -i content-length | awk '{print $2}' | tr -d '\r' || echo "unknown")
                echo "===== Log file: $(basename $logfile) (Size: ${filesize} bytes) ====="
                
				# Download and print the actual log content
                curl -s "http://172.18.0.3:8080/$logfile" 2>/dev/null
                echo "===== End of $(basename $logfile) ====="
                echo ""
                fi
            fi
        done
    done
}

# Start the log polling service
get_logs
```
- Close the editor by pressing `ctrl + S`and `ctrl + X` to save and exit.

## Build the Image
- Inside the `http` directory, build the Docker image with the following command. This will download the required base image, dependencies, and create a new image called `http-server`:
```bash
docker build -t http-server .
```
- After the build completes, you can verify that the image was created successfully by running:
```bash
docker images
```
- You should see `http-server` listed among the available images.

## What We Have Done
- We successfully created a HTTP server that will be used to poll the Snort container for alerts. 
- We built the image and prepared it for use by Terraform in later steps of this tutorial.