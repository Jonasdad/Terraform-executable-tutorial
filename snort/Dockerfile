FROM ubuntu:latest

RUN apt-get update && \
	apt-get install -y snort \
	iputils-ping

COPY devops.rules /etc/snort/rules/

COPY run-snort.sh /etc/snort/

RUN chmod +x /etc/snort/run-snort.sh

ENTRYPOINT ["/etc/snort/run-snort.sh"]
