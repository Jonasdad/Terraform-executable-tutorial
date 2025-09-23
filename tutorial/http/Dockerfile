FROM python:3.9-slim

# Install curl for HTTP requests
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Copy the run script
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Run the server
ENTRYPOINT [ "/usr/local/bin/run.sh" ]