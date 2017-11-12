#!/bin/sh
[[ -f ./cube-artifactdownloader.jar ]] || wget -q -O cube-artifactdownloader.jar `wget -q -O - https://api.github.com/repos/Cube-Earth/ArtifactDownloader/releases/tags/1.0 | grep browser_download_url | cut -d '"' -f 4`

dir="/opt/tomcat/webapps/$1/WEB-INF/lib"

java -jar ./cube-artifactdownloader.jar "$dir" -