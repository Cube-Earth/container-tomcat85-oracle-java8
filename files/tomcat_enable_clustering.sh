#!/bin/sh

currdir=`dirname $0`
cp $currdir/tomcat_adjust_clustering.sh /opt/tomcat/bin/startup
chmod +x /opt/tomcat/bin/startup/tomcat_adjust_clustering.sh

# server.xml
xml ed -s '/Server/Service/Engine' -t elem -n '##ReplaceMe##' -v "" /opt/tomcat/conf/server.xml > /opt/tomcat/conf/server.tmp
awk 'BEGIN{ f=1 } /<##ReplaceMe##\/>/ { f=0 } f==1 { print }' /opt/tomcat/conf/server.tmp > /opt/tomcat/conf/server.xml
cat >> /opt/tomcat/conf/server.xml << EOF
       <Cluster className="org.apache.catalina.ha.tcp.SimpleTcpCluster"
                 channelSendOptions="8">

          <Manager className="org.apache.catalina.ha.session.DeltaManager"
                   expireSessionsOnShutdown="false"
                   notifyListenersOnReplication="true"/>

          <Channel className="org.apache.catalina.tribes.group.GroupChannel">
            <Membership className="org.apache.catalina.tribes.membership.McastService"
                        address="$TOMCAT_CLUSTER_BROADCAST_IP"
                        port="45564"
                        frequency="500"
                        dropTime="3000"/>
            <Receiver className="org.apache.catalina.tribes.transport.nio.NioReceiver"
                      address="auto"
                      port="4000"
                      autoBind="100"
                      selectorTimeout="5000"
                      maxThreads="6"/>

            <Sender className="org.apache.catalina.tribes.transport.ReplicationTransmitter">
              <Transport className="org.apache.catalina.tribes.transport.nio.PooledParallelSender"/>
            </Sender>
            <Interceptor className="org.apache.catalina.tribes.group.interceptors.TcpFailureDetector"/>
            <Interceptor className="org.apache.catalina.tribes.group.interceptors.MessageDispatch15Interceptor"/>
          </Channel>

          <Valve className="org.apache.catalina.ha.tcp.ReplicationValve"
                 filter=""/>
          <Valve className="org.apache.catalina.ha.session.JvmRouteBinderValve"/>

          <Deployer className="org.apache.catalina.ha.deploy.FarmWarDeployer"
                    tempDir="/tmp/war-temp/"
                    deployDir="/tmp/war-deploy/"
                    watchDir="/tmp/war-listen/"
                    watchEnabled="false"/>

          <ClusterListener className="org.apache.catalina.ha.session.JvmRouteSessionIDBinderListener"/>
          <ClusterListener className="org.apache.catalina.ha.session.ClusterSessionListener"/>
        </Cluster>
EOF
awk 'BEGIN{ f=0 } f==1 { print } /<##ReplaceMe##\/>/ { f=1 }' /opt/tomcat/conf/server.tmp >> /opt/tomcat/conf/server.xml

rm /opt/tomcat/conf/server.tmp
