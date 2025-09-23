FROM ubuntu:latest

RUN apt-get update && \
	apt-get install -y snort \
	iputils-ping \
	wget \
	tar \
	sudo \
	curl \
	python3

# Snort setup
COPY devops.rules /etc/snort/rules/
COPY run-snort.sh /etc/snort/
RUN chmod +x /etc/snort/run-snort.sh

# Expose port for HTTP server serving log files
EXPOSE 8080

ENTRYPOINT ["/etc/snort/run-snort.sh"]
