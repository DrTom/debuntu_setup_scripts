cat <<'HEREDOC0' > /etc/logrotate.d/polyglot-as
/var/log/polyglot-as/*.log  /opt/polyglot-as/jboss/standalone/log/*/*.log /home/polyglot-as/*/log/*.log {
daily
missingok
size 1M
rotate 21
compress
delaycompress
notifempty
copytruncate
}
HEREDOC0
logrotate -d -v /etc/logrotate.d/polyglot-as
