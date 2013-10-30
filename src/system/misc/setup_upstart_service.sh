if [[ -z $DIR || -z $NAME || -z $USER || -z $COMMAND || -n $HELP ]]; then
cat <<EOF 
  Sets up a (rather simple) system service.
  
  Requires the following variables to be set:

  DIR absolute path where to cd before starting the service
  NAME name of the service
  USER the user under which the service will run
  COMMAND the command executed 
EOF

else 

DIR_MATCHERS="/var/log/$NAME/*.log" NAME=$NAME debuntu_system_misc_setup_logrotate

UPSTART_SCRIPT_PATH="/etc/init/$NAME.conf"

cat <<INIT_SCRIPT_END > "$UPSTART_SCRIPT_PATH"
description "This is an upstart job file for $NAME"
pre-start script
bash << "EOF"
  sleep 1
  mkdir -p /var/log/$NAME
  chown -R $USER /var/log/$NAME
EOF
end script

start on filesystem and net-device-up IFACE!=eth0
stop on stopped network-services
respawn
respawn limit 10 5

script
bash << "EOF"
  su - $USER
  cd $DIR
  $COMMAND >> /var/log/$NAME/$NAME.log 2>&1
EOF
end script
INIT_SCRIPT_END

echo "The service $NAME has been set up. See $UPSTART_SCRIPT_PATH for tweaking."


fi  
