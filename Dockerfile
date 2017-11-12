FROM cubeearth/oracle-java7-server

# TODO:
# - SSL
# - Tomcat Cluster

RUN wget -q -O /etc/apk/keys/necromancerr@users.noreply.github.com.rsa.pub https://github.com/Cube-Earth/alpine-tools/releases/download/repository%2Fx86_64/necromancerr.users.noreply.github.com.rsa.pub && \
	echo "https://github.com/Cube-Earth/alpine-tools/releases/download/repository" >> /etc/apk/repositories && \
	apk add --no-cache xmlstarlet musl zip tomcat-apr && \
	/usr/glibc-compat/sbin/ldconfig /lib && \
	wget -q -O - `wget -q -O - https://tomcat.apache.org/download-80.cgi | grep -o '<a href *= *"[^"]*' | sed 's#^[^"]*"\(.*\)$#\1#' | grep -E '^http.*/bin/.*8\.0\.[0-9]+\.tar.\gz$'` \
	| tar xzf - -C /opt && \
	ln -s /opt/apache-tomcat* /opt/tomcat && \
	sed -i 's/^shared.loader=/shared.loader=\$\{catalina\.home\}\/shared/' /opt/tomcat/conf/catalina.properties && \
	mkdir /opt/tomcat/config && \
	chmod -R o=rwx /opt/tomcat/* && \
	find /opt/tomcat/bin -type f -name "*.bat" -delete && \
	rm -Rf /opt/tomcat/webapps/docs /opt/tomcat/webapps/examples /opt/tomcat/webapps/host-manager /opt/tomcat/webapps/manager && \
	/usr/glibc-compat/sbin/ldconfig /usr/lib /usr/tomcat-apr/lib && \
	sed -i'' -e 's/^\(common\.loader=.*\)$/\1,"${catalina.home}\/config"/' /opt/tomcat/conf/catalina.properties

COPY files/* /usr/local/bin/
RUN chmod 755 /usr/local/bin/*

USER user
EXPOSE 8080

CMD [ "/usr/local/bin/tomcat_startup.sh" ]
