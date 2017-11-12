#!/bin/sh

# server.xml
xml ed --inplace \
	-u '/Server/Service/Engine/Cluster/Channel/Membership/@address' -v "$TOMCAT_CLUSTER_BROADCAST_IP" \
	/opt/tomcat/conf/server.xml
