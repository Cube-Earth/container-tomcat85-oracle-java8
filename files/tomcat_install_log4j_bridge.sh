#!/bin/sh
[[ -f ./cube-artifactdownloader.jar ]] || wget -q -O cube-artifactdownloader.jar `wget -q -O - https://api.github.com/repos/Cube-Earth/ArtifactDownloader/releases/tags/1.0 | grep browser_download_url | cut -d '"' -f 4`

basedir="/opt/tomcat/webapps/$1/WEB-INF"
libdir="$basedir/lib"
confdir="$basedir/classes"

rm "$libdir/log4j.jar" "$libdir"/log4j-*.jar "$libdir"/jcl-over-slf4j-*.jar "$libdir"/slf4j-ext-*.jar "$libdir"/jul-to-slf4j-*.jar "$libdir"/slf4j-api-*.jar 2>/dev/null

java -jar ./cube-artifactdownloader.jar "$libdir" org.apache.logging.log4j:log4j-1.2-api:2.9.1 org.apache.logging.log4j:log4j-api:2.9.1 org.apache.logging.log4j:log4j-core:2.9.1 com.fasterxml.jackson.dataformat:jackson-dataformat-yaml:2.9.2
java -jar ./cube-artifactdownloader.jar "$libdir" org.slf4j:jcl-over-slf4j:jar:1.7.25 org.slf4j:slf4j-ext:jar:1.7.25 org.slf4j:jul-to-slf4j:jar:1.7.25 org.slf4j:slf4j-api:jar:1.7.25

rm "$libdir"/jeromq-*.jar
echo "repository.0=https://oss.sonatype.org/content/repositories/snapshots" > repositories.properties
java -cp .:./cube-artifactdownloader.jar earth.cube.tools.artifactdownloader.Downloader "$libdir" earth.cube.logkeeper:cube-logkeeper-loggers:1.0-SNAPSHOT

cat >> "$confdir/log4j2.yaml" << EOF
Configuration:
  status: warn
  packages: earth.cube.tools.logkeeper.loggers.log4j2

  Appenders:
    Forward_Appender:
      name: Forward
      application: WebApp
      source: log4j2


  Loggers:
    Root:
      level: info
      AppenderRef:
        ref: Forward

    Logger:
        - name: foo
          level: info
          AppenderRef:
            - ref: Forward
              level: info
EOF
