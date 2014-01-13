cat <<'HEREDOC0' > /etc/init/polyglot-as.conf
description "This is an upstart job file for TorqueBox"

pre-start script
bash << "EOF"
  mkdir -p /var/log/polyglot-as
  chown -R polyglot-as /var/log/polyglot-as
EOF
end script

start on filesystem and net-device-up IFACE!=eth0
stop on stopped network-services
respawn
limit nofile 4096 4096

script
bash << "EOF"
  su - polyglot-as
  export JRUBY_OPTS="--1.9"
  export JAVA_OPTS="-server -Xms64m -Xmx32G -XX:MaxPermSize=2G"
  export JAVA_OPTS="$JAVA_OPTS -Djava.net.preferIPv4Stack=true -Dorg.jboss.resolver.warning=true"
  export JAVA_OPTS="$JAVA_OPTS -Dsun.rmi.dgc.client.gcInterval=3600000 -Dsun.rmi.dgc.server.gcInterval=3600000"
  export JAVA_OPTS="$JAVA_OPTS -Djboss.modules.system.pkgs=$JBOSS_MODULES_SYSTEM_PKGS -Djava.awt.headless=true"
  export JAVA_OPTS="$JAVA_OPTS -Djboss.server.default.config=standalone.xml"
  export POLYGLOT_AS_HOME=/opt/polyglot-application-server/server
  export JBOSS_HOME=${POLYGLOT_AS_HOME}/jboss
  export JRUBY_HOME=${POLYGLOT_AS_HOME}/jruby
  export PATH=${POLYGLOT_AS_HOME}/bin:${JBOSS_HOME}/bin:${JRUBY_HOME}/bin:${PATH}

  ${JRUBY_HOME}/bin/standalone.sh >> /var/log/polyglot-as/polyglot-as.log 2>&1
EOF
end script
HEREDOC0
