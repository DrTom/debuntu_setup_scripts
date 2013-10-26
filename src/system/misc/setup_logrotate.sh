if [[ -z $DIR_MATCHERS || -z $NAME || -n $HELP ]]; then
cat <<EOF 
  Sets up logrotation with sensible defaults. 
  
  Requires the following variables to be set:

  DIR_MATCHERS e.g. "/var/log/torquebox/*.log /home/torquebox/*/log/*.log"
  NAME name 
EOF

else 

LOGROTATE_SCRIPT_PATH="/etc/logrotate.d/$NAME"


cat <<LOGROTATE_SCRIPT_END > "$LOGROTATE_SCRIPT_PATH"
$DIR_MATCHERS {
daily
missingok
size 1M
rotate 21
compress
delaycompress
notifempty
copytruncate
}
LOGROTATE_SCRIPT_END

echo "The logrotation for $NAME has been defined in $LOGROTATE_SCRIPT_PATH"
echo "To manually trigger rotation invoke: \"logrotate -d -v $LOGROTATE_SCRIPT_PATH\""

fi
