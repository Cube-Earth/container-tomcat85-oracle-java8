#!/bin/sh

wget -P /opt/tomcat/lib http://central.maven.org/maven2/org/aspectj/aspectjweaver/1.8.10/aspectjweaver-1.8.10.jar

cat >> /opt/tomcat/bin/setenv.sh << EOF
CATALINA_OPTS="$CATALINA_OPTS -javaagent /opt/tomcat/lib/aspectjweaver-1.8.10.jar -Dorg.aspectj.weaver.Dump.condition=abort -Dorg.aspectj.weaver.Dump.exception=false"
EOF
