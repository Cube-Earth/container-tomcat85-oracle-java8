#!/bin/sh

# web.xml
xml ed -N x='http://xmlns.jcp.org/xml/ns/javaee' -a '/x:web-app/x:servlet[x:servlet-name="jsp"]/x:init-param[position()=last()]' -t elem -n '##ReplaceMe##' -v "" /opt/tomcat/conf/web.xml > /opt/tomcat/conf/web.tmp
awk 'BEGIN{ f=1 } /<##ReplaceMe##\/>/ { f=0 } f==1 { print }' /opt/tomcat/conf/web.tmp > /opt/tomcat/conf/web.xml
cat >> /opt/tomcat/conf/web.xml << EOF
    <init-param>
      <param-name>enablePooling</param-name>
      <param-value>false</param-value>
    </init-param>
EOF
awk 'BEGIN{ f=0 } f==1 { print } /<##ReplaceMe##\/>/ { f=1 }' /opt/tomcat/conf/web.tmp >> /opt/tomcat/conf/web.xml
rm /opt/tomcat/conf/web.tmp
