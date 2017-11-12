#!/bin/sh
[[ -f ./cube-artifactdownloader.jar ]] || wget -q -O cube-artifactdownloader.jar `wget -q -O - https://api.github.com/repos/Cube-Earth/ArtifactDownloader/releases/tags/1.0 | grep browser_download_url | cut -d '"' -f 4`

echo "repository.0=https://oss.sonatype.org/content/repositories/snapshots" > repositories.properties
java -cp .:./cube-artifactdownloader.jar earth.cube.tools.artifactdownloader.Downloader /opt/tomcat/bin earth.cube.logkeeper:cube-logkeeper-delegates:1.0-SNAPSHOT
java -cp .:./cube-artifactdownloader.jar earth.cube.tools.artifactdownloader.Downloader /opt/tomcat/lib earth.cube.logkeeper:cube-logkeeper-tomcat:1.0-SNAPSHOT

mkdir /opt/tomcat/bin/logkeeper
java -cp .:./cube-artifactdownloader.jar earth.cube.tools.artifactdownloader.Downloader /opt/tomcat/bin/logkeeper earth.cube.logkeeper:cube-logkeeper-loggers:1.0-SNAPSHOT

jar=`find /opt/tomcat/bin -type f -maxdepth 1 -name "cube-logkeeper-delegates-*.jar" -exec basename "{}" \;`
#jar2=`find /opt/tomcat/bin -type f -maxdepth 1 -name "cube-logkeeper-tomcat-*.jar" -exec basename "{}" \;`

echo "CLASSPATH=\$CLASSPATH\${CLASSPATH+:}\$CATALINA_HOME/bin/$jar" >> /opt/tomcat/bin/setenv.sh

xml ed --inplace -i '/Server/Listener[position()=1]' -t elem -n 'Listener' -v "" -i '$prev' -t attr -n className -v "earth.cube.tools.logkeeper.tomcat.TomcatStreamRedirector" /opt/tomcat/conf/server.xml 

cat > /opt/tomcat/conf/logging.properties << EOF
handlers = 1catalina.earth.cube.tools.logkeeper.delegates.java_logging.ForwardHandler, 2localhost.earth.cube.tools.logkeeper.delegates.java_logging.ForwardHandler

.handlers = 1catalina.earth.cube.tools.logkeeper.delegates.java_logging.ForwardHandler

############################################################
# Handler specific properties.
# Describes specific configuration info for Handlers.
############################################################

1catalina.earth.cube.tools.logkeeper.delegates.java_logging.ForwardHandler.level = FINE
1catalina.earth.cube.tools.logkeeper.delegates.java_logging.ForwardHandler.application = Tomcat
1catalina.earth.cube.tools.logkeeper.delegates.java_logging.ForwardHandler.source = catalina

2localhost.earth.cube.tools.logkeeper.delegates.java_logging.ForwardHandler.level = FINE
2localhost.earth.cube.tools.logkeeper.delegates.java_logging.ForwardHandler.application = Tomcat
2localhost.earth.cube.tools.logkeeper.delegates.java_logging.ForwardHandler.source = localhost


############################################################
# Facility specific properties.
# Provides extra control for each logger.
############################################################

org.apache.catalina.core.ContainerBase.[Catalina].[localhost].level = INFO
org.apache.catalina.core.ContainerBase.[Catalina].[localhost].handlers = 2localhost.earth.cube.tools.logkeeper.delegates.java_logging.ForwardHandler
EOF
