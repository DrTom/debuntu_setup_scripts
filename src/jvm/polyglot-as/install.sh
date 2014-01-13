REPOSITORY_URL="https://github.com/DrTom/polyglot-application-server.git"
COMMIT="6ace9d74c14dfcbd91c596d64df8e0f4d4327758"
TARGET_DIR="/opt/polyglot-application-server"
LOGDIR="/var/log/polyglot-as/"
WORKDIR=`pwd`

service polyglot-as stop
pkill -SIGTERM -f 'java.*polyglot-as' 
pkill -SIGKILL -f 'java.*polyglot-as' 


### installing prerequisites
debuntu_jvm_open_jdk_install

adduser --disabled-password -gecos "" polyglot-as

if [[ ! -d $TARGET_DIR ]]; then
  git clone "${REPOSITORY_URL}" ${TARGET_DIR}
  chown -R polyglot-as $TARGET_DIR
fi

cd $TARGET_DIR
if [[  `git rev-parse --verify HEAD` != $COMMIT ]]; then
  git fetch origin -p +refs/heads/*:refs/heads/*
  rm -rf server 
  git reset --hard $COMMIT
  chown -R polyglot-as $TARGET_DIR
fi

cd $WORKDIR

mkdir -p $LOGDIR
chown -R polyglot-as $LOGDIR

debuntu_jvm_polyglot_setup-logrotate
debuntu_jvm_polyglot-as_setup-start-stop-scripts
service polyglot-as start


