FROM ubuntu:latest

RUN apt-get update && \
	apt-get install -y snort \
	iputils-ping \
	wget \
	tar \
	sudo

# Splunk forwarder setup
ENV SPLUNK_HOME="/opt/splunkforwarder"
RUN useradd -m splunk
WORKDIR /opt
RUN wget -O splunkforwarder-10.0.0-e8eb0c4654f8-linux-amd64.tgz "https://download.splunk.com/products/universalforwarder/releases/10.0.0/linux/splunkforwarder-10.0.0-e8eb0c4654f8-linux-amd64.tgz"
RUN tar xvzf splunkforwarder-10.0.0-e8eb0c4654f8-linux-amd64.tgz
RUN chown -R splunk:splunk $SPLUNK_HOME
RUN rm splunkforwarder-10.0.0-e8eb0c4654f8-linux-amd64.tgz
COPY inputs.conf $SPLUNK_HOME/etc/system/local/

# Snort setup
COPY devops.rules /etc/snort/rules/
COPY run-snort.sh /etc/snort/
RUN chmod +x /etc/snort/run-snort.sh

ENTRYPOINT ["/etc/snort/run-snort.sh"]
