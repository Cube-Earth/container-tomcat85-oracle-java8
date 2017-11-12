#!/bin/sh
export LD_LIBRARY_PATH=/usr/tomcat-apr/lib:$LD_LIBRARY_PATH
IFS=$'\n'
if [[ -d /opt/tomcat/bin/startup ]]
then
	for f in `ls -d /opt/tomcat/bin/startup/*.sh 2>/dev/null`
	do
		echo "executing $f ..."
		echo
		"$f"
	done
fi
echo "starting tomcat ..."
echo
/opt/tomcat/bin/catalina.sh run
