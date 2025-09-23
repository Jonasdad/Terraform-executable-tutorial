#!/bin/bash

get_logs() {
    echo "Starting log polling service..."
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