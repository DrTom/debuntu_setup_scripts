stop domina
MATCHER='java.*domina'
pgrep -f "$MATCHER"
if [ $? -ne 0 ]; then
  sleep 10
  pkill -SIGTERM -f "$MATCHER"
fi
pgrep -f "$MATCHER"
if [ $? -ne 0 ]; then
  sleep 10
  pkill -SIGKILL -f "$MATCHER"
fi
stop domina

debuntu_invoke_as_user domina debuntu_zhdk_domina-ci-executor_as-domina-setup

cat <<'EOF' > /etc/logrotate.d/domina
var/log/domina/*.log {
  daily
  missingok
  size 1M
  rotate 21
  compress
  delaycompress
  notifempty
  copytruncate
}
EOF

cp /home/domina/domina_ci_executor/doc/upstart-domina.conf /etc/init/domina.conf
start domina
