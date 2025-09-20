#!/bin/bash

# https://help.splunk.com/en/splunk-cloud-platform/forward-and-process-data/universal-forwarder-manual/9.0/configure-the-universal-forwarder/enable-a-receiver-for-splunk-enterprise#id_8dd83488_23ef_4bc4_94ee_d4ca8aa9cfeb__Enable_a_receiver_for_Splunk_Enterprise

$SPLUNK_HOME/bin/splunk enable listen 9997 -auth admin:password

$SPLUNK_HOME/bin/splunk start --accept-license