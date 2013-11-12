service domina stop
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
service domina stop
debuntu_invoke_as_user domina debuntu_zhdk_domina-slave_domina-ci-executor_as-domina-setup

DIR=/home/domina/domina_ci_executor/ NAME=domina USER=domina debuntu_jvm_leiningen_setup_system_service

start domina
