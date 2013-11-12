TB_URL="http://torquebox.org/release/org/torquebox/torquebox-dist/3.0.0/torquebox-dist-3.0.0-bin.zip"
TB_VERSION="3.0.0"
TB_ROOT="/opt/torquebox-3.0.0"

TMP_FILE="/tmp/torquebox-${TB_VERSION}.zip"
TB_LINK="/opt/torquebox"

service torquebox stop
MATCHER='java.*jar.*torquebox'
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

### installing prerequisites
debuntu_jvm_open_jdk_install

### do it 
adduser --disabled-password -gecos "" torquebox
if [ ! -f ${TMP_FILE} ]; then
  curl -L "$TB_URL" > "$TMP_FILE"
fi
rm -rf ${TB_ROOT}
unzip "$TMP_FILE" -d /opt
chown -R torquebox "${TB_ROOT}"
rm -f ${TB_LINK}
ln -s ${TB_ROOT} ${TB_LINK}

LOGDIR="/var/log/torquebox/"
mkdir -p $LOGDIR
chown -R torquebox $LOGDIR

debuntu_torquebox_setup_env_loader
debuntu_torquebox_setup_logrotate
debuntu_torquebox_setup_start_stop_scripts

service torquebox start
