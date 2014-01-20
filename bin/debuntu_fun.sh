function debuntu_ci_chromedriver_install {
TMDIR=`mktemp -d`
cd $TMDIR
MACHINE_BITS=`uname -m | cut -d '_' -f 2`
curl -s -L "http://chromedriver.storage.googleapis.com/2.8/chromedriver_linux${MACHINE_BITS}.zip" > chromedriver.zip
unzip chromedriver.zip
mv chromedriver ~/bin
cd
rm -rf $TMDIR
}

function debuntu_ci_domina-ci-executor_install {
VERSION=$1
TARGET_DIR="${HOME}/domina_ci_executor"
rm -rf "${TARGET_DIR}" \
&& git clone https://github.com/DrTom/domina-ci-executor.git ${TARGET_DIR} \
&& cd "$TARGET_DIR" \
&& git fetch --all \
&& if [ -n $VERSION ]; then
  git checkout $VERSION
fi
}

function debuntu_ci_phantomjs_install {
mkdir -p ~/bin
MACHINE=`uname -m`
TMDIR=`mktemp -d`
cd $TMPDIR
curl "https://phantomjs.googlecode.com/files/phantomjs-1.9.0-linux-${MACHINE}.tar.bz2" | tar xj
cp phantomjs-1.9.0-linux-x86_64/bin/phantomjs ~/bin/
cd
rm -rf $TMPDIR
}

function debuntu_ci_tightvnc_install {
echo "INSTALLING tightvncserver"
apt-get install --assume-yes git x11vnc fluxbox tightvncserver
}

function debuntu_ci_tightvnc_user_setup {
# 
# example for starting and killing a display serer:
# export DISPLAY_NUMBER=5900
# tightvncserver :$DISPLAY_NUMBER -geometry 1024x768 -rfbport $DISPLAY_NUMBER -interface 0.0.0.0
# tightvncserver -kill :$DISPLAY_NUMBER -clean

rm -rf ~/.vnc
mkdir -p ~/.vnc
echo "$USER" | tightvncpasswd -f > ~/.vnc/passwd
chmod go-rw ~/.vnc/passwd

cat <<'EOF' > ~/.vnc/xstartup
#!/bin/sh
xrdb $HOME/.Xresources
xsetroot -solid grey
#x-terminal-emulator -geometry 80x24+10+10 -ls -title "$VNCDESKTOP Desktop" &
#x-window-manager &
# Fix to make GNOME work
fluxbox &
export XKL_XMODMAP_DISABLE=1
/etc/X11/Xsession
EOF
chmod a+x ~/.vnc/xstartup


}

function debuntu_database_postgresql_add_pgdg_apt_repository {
#!/bin/sh

# script to add apt.postgresql.org to sources.list

# from command like
CODENAME="$1"
# lsb_release is the best interface, but not always available
if [ -z "$CODENAME" ]; then
    CODENAME=$(lsb_release -cs 2>/dev/null)
fi
# parse os-release (unreliable, does not work on Ubuntu)
if [ -z "$CODENAME" -a -f /etc/os-release ]; then
    . /etc/os-release
    # Debian: VERSION="7.0 (wheezy)"
    # Ubuntu: VERSION="13.04, Raring Ringtail"
    CODENAME=$(echo $VERSION | sed -ne 's/.*(\(.*\)).*/\1/')
fi
# guess from sources.list
if [ -z "$CODENAME" ]; then
    CODENAME=$(grep '^deb ' /etc/apt/sources.list | head -n1 | awk '{ print $3 }')
fi
# complain if no result yet
if [ -z "$CODENAME" ]; then
    cat <<EOF
Could not determine the distribution codename. Please report this as a bug to
pgsql-pkg-debian@postgresql.org. As a workaround, you can call this script with
the proper codename as parameter, e.g. "$0 squeeze".
EOF
    exit 1
fi

# errors are non-fatal above
set -e

cat <<EOF
This script will enable the PostgreSQL APT repository on apt.postgresql.org on
your system. The distribution codename used will be $CODENAME-pgdg.

EOF

case $CODENAME in
    # known distributions
    sid|wheezy|squeeze|lenny|etch) ;;
    precise|lucid) ;;
    *) # unknown distribution, verify on the web
  DISTURL="http://apt.postgresql.org/pub/repos/apt/dists/"
  if [ -x /usr/bin/curl ]; then
      DISTHTML=$(curl -s $DISTURL)
  elif [ -x /usr/bin/wget ]; then
      DISTHTML=$(wget --quiet -O - $DISTURL)
  fi
  if [ "$DISTHTML" ]; then
      if ! echo "$DISTHTML" | grep -q "$CODENAME-pgdg"; then
    cat <<EOF
Your system is using the distribution codename $CODENAME, but $CODENAME-pgdg
does not seem to be a valid distribution on
$DISTURL

We abort the installation here. Please ask on the mailing list for assistance.

pgsql-pkg-debian@postgresql.org
EOF
    exit 1
      fi
  fi
  ;;
esac

echo "Writing /etc/apt/sources.list.d/pgdg.list ..."
cat > /etc/apt/sources.list.d/pgdg.list <<EOF
deb http://apt.postgresql.org/pub/repos/apt/ $CODENAME-pgdg main
#deb-src http://apt.postgresql.org/pub/repos/apt/ $CODENAME-pgdg main
EOF

echo "Importing repository signing key ..."
KEYRING="/etc/apt/trusted.gpg.d/apt.postgresql.org.gpg"
test -e $KEYRING || touch $KEYRING
apt-key --keyring $KEYRING add - <<EOF
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.12 (GNU/Linux)

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
VPZ67j5UMxqtT/Y4+NHcQGgwF/1i
=Iugu
-----END PGP PUBLIC KEY BLOCK-----
EOF

echo "Running apt-get update ..."
apt-get update

cat <<EOF

You can now start installing packages from apt.postgresql.org.

Have a look at https://wiki.postgresql.org/wiki/Apt for more information;
most notably the FAQ at https://wiki.postgresql.org/wiki/Apt/FAQ
EOF
}

function debuntu_database_postgresql_add_superuser {
echo "ADDING SUPERUSER $1 TO POSTGRES"
PG_USER=$1
cat << HEREDOC0 | su -l postgres -c psql
CREATE USER "$PG_USER" superuser createdb login;
ALTER USER "$PG_USER" WITH PASSWORD '$PG_USER';
CREATE DATABASE "$PG_USER" ;
GRANT ALL ON DATABASE "$PG_USER" TO "$PG_USER";
HEREDOC0
}

function debuntu_database_postgresql_install_9.2 {
debuntu_database_postgresql_add_pgdg_apt_repository
apt-get install --assume-yes postgresql-9.2 postgresql-client-9.2 postgresql-contrib-9.2 postgresql-server-dev-9.2
}

function debuntu_database_riak-cs_complete-setup {
debuntu_database_riak-cs_sub_add-basho-apt-repository
debuntu_database_riak-cs_sub_install
debuntu_database_riak-cs_sub_configure
debuntu_database_riak-cs_sub_setup-admin
etckeeper commit 'configured riak-cs'
}

function debuntu_database_riak-cs_sub_add-basho-apt-repository {
curl http://apt.basho.com/gpg/basho.apt.key | apt-key add -

cat > /etc/apt/sources.list.d/basho.list <<EOF
deb http://apt.basho.com $(lsb_release -sc) main 
EOF

apt-get update
}

function debuntu_database_riak-cs_sub_configure {

/etc/init.d/riak-cs stop
/etc/init.d/stanchion stop
/etc/init.d/riak stop

ulimit -n 65536

cat <<'EOF' > /etc/security/limits.d/riak.conf 
# ulimit settings for Riak CS
root soft nofile 65536
root hard nofile 65536
riak soft nofile 65536
riak hard nofile 65536
EOF

curl "https://raw.github.com/DrTom/debuntu_setup_scripts/master/data/riak-cs-config.patch" | git apply --directory /etc

etckeeper commit "Configured riak-cs"

/etc/init.d/riak start
/etc/init.d/stanchion start
/etc/init.d/riak-cs start
sleep 3
}

function debuntu_database_riak-cs_sub_install {
apt-get --assume-yes install riak riak-cs stanchion
/etc/init.d/riak start
/etc/init.d/stanchion start
/etc/init.d/riak-cs start
}

function debuntu_database_riak-cs_sub_setup-admin {
apt-get install -y ruby1.9.3 

/etc/init.d/stanchion restart
/etc/init.d/riak-cs restart

sleep 5

ruby <<'EOF' 

require 'json'
require 'net/http'
require 'rubygems'


req = Net::HTTP::Post.new('/riak-cs/user', initheader = {'Content-Type' =>'application/json'})
req.body = {email:"#{rand}@example.com", name:"admin user #{rand}"}.to_json 
response = Net::HTTP.new('localhost', '8282').start {|http| http.request(req) }
puts "Response #{response.code} #{response.message}: #{response.body}"

data= JSON.parse response.body

access_key= data["key_id"]
secret_key= data["key_secret"]


%w(/etc/riak-cs/app.config /etc/stanchion/app.config).each do |filepath|
  puts "processing #{filepath}"
  s = IO.read(filepath) \
    .gsub(/{admin_key\s*,\s*"\S*"\s*}/, %<{admin_key,"#{access_key}"}>) \
    .gsub(/{admin_secret\s*,\s*"\S*"\s*}/, %<{admin_secret,"#{secret_key}"}>)
  IO.write(filepath,s)
end

IO.write("/etc/profile.d/riak_cs_cred.sh", %<
export RIAK_CS_ACCESS_KEY='#{access_key}'
export RIAK_CS_SECRET_KEY='#{secret_key}'
export RIAK_CS_PORT=8282
>)

puts "Access-Key: #{access_key}"
puts "Secret-Key: #{secret_key}"

EOF

/etc/init.d/stanchion restart
/etc/init.d/riak-cs restart

cat <<'EOF'
Riak cs admin is configured. See and source '/etc/profile.d/riak_cs_cred.sh'.
EOF
}

function debuntu_invoke_as_user {
TEMPFILE=`mktemp /tmp/debuntu-fun-XXXXXX`
chmod a+rx $TEMPFILE
debuntu_meta_write_functions_for_sourcing $TEMPFILE
cat <<HEREDOC0 | su -l $1
source $TEMPFILE
$2 '$3' '$4' 
HEREDOC0
rm -f $TEMPFILE
}

function debuntu_jvm_leiningen_install {
mkdir -p ~/bin
curl -s "https://raw.github.com/technomancy/leiningen/stable/bin/lein" > ~/bin/lein
chmod a+x ~/bin/lein
~/bin/lein
}

function debuntu_jvm_leiningen_setup_system_service {
if [[ -z $DIR || -z $NAME || -z $USER || -n $HELP ]]; then
cat <<EOF 
  Installs a clojure/leinigen project as a systems service.
  
  Requires the following variables to be set:

  DIR absolute path to the leiningen project
  NAME name of the service
  USER the user under which the service will run
EOF

else 


DIR="$DIR" NAME="$NAME" USER="$USER" COMMAND="lein trampoline run" debuntu_system_misc_setup_upstart_service 


fi  
}

function debuntu_jvm_open_jdk_install {
OS_ID=`debuntu_system_meta_os-name`
echo "Installing open-jdk for \"$OS_ID\""
case "$OS_ID" in
  'Ubuntu/precise'|'Debian/jessie')
    apt-get install --assume-yes openjdk-7-jre-headless openjdk-7-jdk visualvm
    ;;
  'Debian/wheezy')
    apt-get install --assume-yes openjdk-7-jre-headless openjdk-7-jdk 
    ;;
  *)
    echo "none OS matched!!!"
    ;;
esac
update-alternatives --set java /usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java
update-alternatives --set javac /usr/lib/jvm/java-7-openjdk-amd64/bin/javac
}

function debuntu_jvm_polyglot-as_install {
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


}

function debuntu_jvm_polyglot-as_setup-init {
cat <<'HEREDOC0' > /etc/init.d/polyglot-as
#!/bin/bash -e
#
# Example init.d script with LSB support.
#
# Please read this init.d carefully and modify the sections to
# adjust it to the program you want to run.
#
# Copyright 2012 Dominique Broeglin <dominique.broeglin@gmail.com>
# Copyright 2007 Javier Fernandez-Sanguino <jfs@debian.org>
# Copyright 2009 Philipp Hübner <philipp.huebner@credativ.de>
#
# This is free software; you may redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2,
# or (at your option) any later version.
#
# This is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License with
# the Debian operating system, in /usr/share/common-licenses/GPL;  if
# not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA 02111-1307 USA
#
### BEGIN INIT INFO
# Provides:          polyglot-as
# Required-Start:    $network $local_fs
# Required-Stop:
# Should-Start:      $named
# Should-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Polyglot Application Server 
# Description:       Polyglot Application Server based on JBoss AS 7 slim
### END INIT INFO

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

. /lib/lsb/init-functions

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

POLYGLOT_AS_SERVER=standalone.xml
RUN=yes

NAME=polyglot-as
DESC="Polyglot Application Server"
LOGDIR=/var/log/$NAME
LOGFILE=$LOGDIR/$NAME.log
PIDFILE=/var/run/$NAME.pid
DIETIME=15
STARTTIME=10
DAEMONUSER=polyglot-as

#POLYGLOT_AS_HOME=/usr/share/$NAME
# . /etc/default/$NAME || exit 1

POLYGLOT_AS_START="$POLYGLOT_AS_HOME/jboss/bin/standalone.sh"
POLYGLOT_AS_STOP="$POLYGLOT_AS_HOME/jboss/bin/jboss-cli.sh --connect command=:shutdown"


if [ "x$RUN" != "xyes" ] ; then
  log_warning_msg "$NAME disabled, please adjust the configuration to your needs "
  log_warning_msg "and then set RUN to 'yes' in /etc/default/$NAME to enable it."
  exit 0
fi


if getent passwd | grep -q "^$DAEMONUSER:"; then
  DAEMONUID=`getent passwd | grep "^$DAEMONUSER:" | awk -F : '{print $3}'`
  DAEMONGID=`getent passwd | grep "^$DAEMONUSER:" | awk -F : '{print $4}'`
else
  log_failure_msg "The user $DAEMONUSER, required to run $NAME does not exist."
  exit 1
fi


set -e


running() {
  PID=`ps -fu polyglot-as | grep jboss-modules.jar | grep -v grep | awk {'print $2'}`
  if [[ -f /proc/$PID/cmdline && -n $PID ]] ; then
    return 0
  else
    return 1
  fi
}

start_server() {
  echo "`date`: Starting $DESC: $POLYGLOT_AS_SERVER" >> $LOGFILE
  log_progress_msg "(this will take $STARTTIME seconds) "
  start-stop-daemon --start --quiet --chuid $DAEMONUSER  \
    --exec $POLYGLOT_AS_START --pidfile $PIDFILE --make-pidfile -- -c $POLYGLOT_AS_SERVER >> $LOGFILE 2>&1 &
  sleep $STARTTIME
  if running ; then
    log_success_msg "- successfully started"
    log_success_msg "It might take a while until $NAME is completely booted"
    echo "`date`: Successfully started." >> $LOGFILE
  else
    log_failure_msg "- starting failed"
    echo "`date`: Starting failed." >> $LOGFILE
  fi
}

stop_server() {
  echo "`date`: Stopping $DESC: $POLYGLOT_AS_SERVER" >> $LOGFILE
  log_progress_msg "(this will take $DIETIME seconds) "
  $POLYGLOT_AS_STOP >> $LOGFILE 2>&1
  sleep $DIETIME
  if running ; then
    log_failure_msg "- stopping failed. Try $0 force-stop "
    echo "`date`: Stopping failed. Try $0 force-stop ." >> $LOGFILE
  else
    rm -f $PIDFILE
    log_success_msg "- successfully stopped"
    echo "`date`: Successfully stopped." >> $LOGFILE
  fi
}

force_stop_server() {
  echo "`date`: Stopping (force) $NAME with pkill" >> $LOGFILE
  pkill -u polyglot-as >> $LOGFILE
  sleep $DIETIME
  if running ; then
    echo "`date`: Stopping (force) $NAME with pkill -9" >> $LOGFILE
    pkill -9 -u polyglot-as >> $LOGFILE
  fi
  if running ; then
    echo "`date`: force-stop failed." >> $LOGFILE
    log_failure_msg "force-stop failed"
  else
    rm -f $PIDFILE
    echo "`date`: force-stop succeeded." >> $LOGFILE
    log_success_msg "force-stop succeeded"
  fi
}


case "$1" in
  start)
    log_begin_msg "Starting $DESC: $POLYGLOT_AS_SERVER "
    if running ; then
      echo "`date`: $NAME running, therefore not trying to start" >> $LOGFILE
      log_success_msg "- apparently already running"
    else
      start_server
    fi
    ;;

  stop)
    if [ $POLYGLOT_AS_SERVER == "minimal" ] || [ $POLYGLOT_AS_SERVER == "web" ] ; then
      $0 force-stop
    else
      log_begin_msg "Stopping $DESC: $POLYGLOT_AS_SERVER "
      if running ; then
        stop_server
      else
        echo "`date`: $NAME not running, therefore not trying to stop" >> $LOGFILE
        log_success_msg "- apparently not running"
      fi
    fi
    ;;

  force-stop)
    log_begin_msg "Force-stopping $DESC: $POLYGLOT_AS_SERVER "
    if running ; then
      force_stop_server
    else
      echo "`date`: $NAME not running, therefore not trying to stop" >> $LOGFILE
      log_success_msg "- apparently not running"
    fi
    ;;

  restart|force-reload)
    if [ $POLYGLOT_AS_SERVER == "minimal" ] || [ $POLYGLOT_AS_SERVER == "web" ] ; then
      log_begin_msg "Force-stopping $DESC: $POLYGLOT_AS_SERVER "
      if running ; then
        force_stop_server
      else
        echo "`date`: $NAME not running, therefore not trying to stop" >> $LOGFILE
        log_warning_msg "- apparently not running"
        exit 0
      fi
    else
      log_begin_msg "Stopping $DESC: $POLYGLOT_AS_SERVER "
      if running ; then
        stop_server
      else
        echo "`date`: $NAME not running, therefore not trying to stop" >> $LOGFILE
        log_warning_msg "- apparently not running"
        exit 0
      fi
    fi
    log_begin_msg "Starting $DESC: $POLYGLOT_AS_SERVER "
    if running ; then
      echo "`date`: $NAME running, therefore not trying to start" >> $LOGFILE
      log_success_msg "- apparently already running"
    else
      start_server
    fi
    ;;

  status)
    log_begin_msg "Checking status of $DESC: $POLYGLOT_AS_SERVER "
    echo "`date`: Checking status of $DESC: " >> $LOGFILE
    if running ; then
      log_success_msg "- apparently running"
      echo "`date`: $NAME - apparently running" >> $LOGFILE
    else
      log_warning_msg "- apparently not running"
      echo "`date`: $NAME - apparently not running" >> $LOGFILE
    fi
    ;;

  reload)
    log_warning_msg "Reloading $NAME daemon: not implemented, as the daemon \
    cannot re-read the config file (use restart)."
    ;;

  *)
    N=/etc/init.d/$NAME
    echo "Usage: $N {start|stop|force-stop|restart|force-reload|status}" >&2
    exit 1
    ;;

esac

exit 0
HEREDOC0

chmod a+x /etc/init.d/polyglot-as
}

function debuntu_jvm_polyglot-as_setup-logrotate {
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
}

function debuntu_jvm_polyglot-as_setup-start-stop-scripts {
case `debuntu_system_meta_os-name` in
  Debian*)
    debuntu_jvm_polyglot-as_setup-init
    ;;
  Ubuntu*)
    debuntu_jvm_polyglot-as_setup-upstart
    ;;
esac
}

function debuntu_jvm_polyglot-as_setup-upstart {
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
}

function debuntu_meta_echo_test {
echo "I am `whoami`"
echo "ARG1 $1"
echo "ARG2 $2"
}

function debuntu_meta_write_functions_for_sourcing {
FUNLIST=`declare -F | grep -e "^declare -f debuntu" | cut -f3 -d ' '`
FUNCTIONS=`declare -f $FUNLIST`
echo "$FUNCTIONS" > "$1"
}

function debuntu_my_drtom_add_ssh_key {
debuntu_ssh_download_and_add_to_authorized_keys "https://raw.github.com/DrTom/debuntu_setup_scripts/master/data/keys/drtom"
}

function debuntu_my_drtom_setup {
debuntu_my_drtom_setup_bashrc
debuntu_my_drtom_setup_git
debuntu_my_drtom_add_ssh_key
}

function debuntu_my_drtom_setup_bashrc {
cat <<'EOF' > ~/.bashrc

set -o vi

export PATH="${HOME}/bin:${PATH}"

export EDITOR=vim

# fancy prompt

if [ "`id -u`" -eq 0 ]; then
  CCODE='\[\033[01;31m\]'
else
  CCODE='\[\033[01;32m\]'
fi

_PS1 ()
{
    local PRE= NAME="$1" LENGTH="$2";
    [[ "$NAME" != "${NAME#$HOME/}" || -z "${NAME#$HOME}" ]] &&
        PRE+='~' NAME="${NAME#$HOME}" LENGTH=$[LENGTH-1];
    ((${#NAME}>$LENGTH)) && NAME="/…${NAME:$[${#NAME}-LENGTH+4]}";
    echo "$PRE$NAME"
}

PS1=${CCODE}'\u\[\033[00m\]@\[\033[01;33m\]\h\[\033[00m\]:\[\033[01;34m\]$(_PS1 "$PWD" 20)\[\033[00m\]\$ '



# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize


function source_debuntu_master {
  source <(curl https://raw.github.com/DrTom/debuntu_setup_scripts/master/bin/debuntu_fun.sh)
}

function source_debuntu_wip {
    source <(curl https://raw.github.com/DrTom/debuntu_setup_scripts/wip/bin/debuntu_fun.sh)
}

EOF

}

function debuntu_my_drtom_setup_git {
cat <<'EOF' > ~/.gitconfig
[color]
  diff = auto
  status = auto
  branch = auto
  ui = true
[user]
	name = Thomas Schank
	email = DrTom@schank.ch

[diff]
  tool = default-difftool

[difftool]      
  prompt = false  

[alias]
	lg = log --oneline
  current-branch = !git symbolic-ref -q HEAD | sed -e 's|^refs/heads/||'
  ld = log --pretty=oneline --abbrev-commit --graph --decorate
  l = log --graph --pretty=format':%C(yellow)%h%Cblue%d%Creset %s %C(white) %an, %ar, commited %cr %Creset'
  lol = log --pretty=oneline --abbrev-commit --graph --decorate
  staged = diff --cached
  track = checkout -t
  unstaged = diff
  co = checkout

[apply]
    whitespace = warn

[help]
    autocorrect = 1

[status]
    submodule = 1

[push]
    # Only push branches that have been set up to track a remote branch.
    #   default = current
[core]
	excludesfile = /Users/thomas/.gitignore_global

#[difftool "default-difftool"]
#  cmd = /Users/thomas/bin/gitdifftool $LOCAL $REMOTE
#[difftool "sourcetree"]
#	cmd = opendiff \"$LOCAL\" \"$REMOTE\"
#	path = 
#[mergetool "sourcetree"]
#	cmd = /Applications/SourceTree.app/Contents/Resources/opendiff-w.sh \"$LOCAL\" \"$REMOTE\" -ancestor \"$BASE\" -merge \"$MERGED\"
#	trustExitCode = true
 
[push]
	default = matching
EOF

}

function debuntu_rails-server_install_apache_httpd {
apt-get install -y apache2
a2enmod proxy_http
a2enmod headers
a3enmod expires
}

function debuntu_rails-server_setup-as-polyglot-as {
debuntu_ruby_rbenv_install
debuntu_ruby_rbenv_install_ruby_2.0.0
debuntu_ruby_rbenv_install_jruby_1.7
}

function debuntu_rails-server_setup {
# debuntu_jvm_polyglot-as_install
debuntu_database_postgresql_install_9.2
debuntu_database_postgresql_add_superuser polyglot-as
debuntu_ruby_rbenv_prepare-system
debuntu_invoke_as_user polyglot-as debuntu_rails-server_setup-as-polyglot-as
}

function debuntu_ruby_rbenv_install {
curl https://raw.github.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash
}

function debuntu_ruby_rbenv_install_jruby_1.7 {
if [[ -n $HELP ]]; then
cat <<EOF 

  Install latest jruby 1.7 and remove all older 1.7 versions
  This version is then kown to rbenv by jruby-1.7
 
  optional vars:

  KEEP (non empty string) will preserve the currently existing if it is up to the lates patchlevel.
EOF
return
fi

CURRENT='jruby-1.7.9'
LINK='jruby-1.7'
declare -a OLD_VERSIONS=("jruby-1.7.4" "jruby-1.7.5")

OLD_VERSIONS=$OLD_VERSIONS CURRENT=$CURRENT LINK=$LINK KEEP=$KEEP debuntu_ruby_rbenv_install_latest
}

function debuntu_ruby_rbenv_install_latest {
if [[ -z $LINK || -z $CURRENT || -z ${OLD_VERSIONS} || -n $HELP ]]; then
cat <<EOF 

  required vars: 

  OLD_VERSIONS ($OLD_VERSION)
  CURRENT ($CURRENT)
  LINK ($LINK)

  optional vars:

  KEEP_OLD_VERSIONS
  KEEP

EOF
return
fi

VERSIONS_DIR="${HOME}"/.rbenv/versions

for V in ${OLD_VERSIONS[@]}; do
  echo "removing $V if exists"
  rm -rf  "$VERSIONS_DIR"/"${V}"
done 


if [[ -n $KEEP ]]; then
  echo "keeping current if exists; checking $VERSIONS_DIR/$CURRENT"
  if [ ! -d "$VERSIONS_DIR/$CURRENT" ]; then
    echo "did not found existing $CURRENT ruby, installing ... " 
    VERSION=$CURRENT LINK=$LINK debuntu_ruby_rbenv_install_ruby 
  else
    echo "found existing $CURRENT ruby, done." 
  fi
else
  echo "forcing reinstall"
  rm -rf "$VERSIONS_DIR"/"$CURRENT"
  VERSION=$CURRENT LINK=$LINK debuntu_ruby_rbenv_install_ruby 
fi

if [[ -n $LINK ]]; then 
  echo "resetting link"
  rm -f "$VERSIONS_DIR/$LINK";
  ln -s  "$VERSIONS_DIR/$CURRENT" "$VERSIONS_DIR/$LINK";
else
  echo "no link given"
fi
}

function debuntu_ruby_rbenv_install_ruby {
if [[ -z $VERSION || -n $HELP ]]; then
cat <<EOF 
  
  Install a ruby version. 
  
  required vars: 

    VERSION 

    e.g. VERSION='2.0.0-p247'

  optional vars: 

    LINK

    e.g. LINK='ruby-2.0.0'
EOF
return 
fi


source /etc/profile.d/rbenv.sh
load_rbenv;
rbenv install -f $VERSION;
rbenv shell $VERSION;
rbenv rehash;
gem update --system;
gem install rubygems-update;
gem install bundler;
rbenv rehash;

if [[ -n $LINK ]]; then 
  rm -f ~/.rbenv/versions/$LINK;
  ln -s  ~/.rbenv/versions/$VERSION/ ~/.rbenv/versions/$LINK;
fi

}

function debuntu_ruby_rbenv_install_ruby_1.9.3 {
if [[ -n $HELP ]]; then
cat <<EOF 

  Install latest ruby 2.0.0 and remove all other patcheѕ.
  This version is then kown to rbenv by ruby-2.0.0.
 
  optional vars:

  KEEP (non empty string) will preserve the currently existing if it is up to the lates patchlevel.
EOF
return
fi

CURRENT='1.9.3-p448'
LINK='ruby-1.9.3'
declare -a OLD_VERSIONS=("1.9.3-p0" "1.9.3-p125" "1.9.3-p194" "1.9.3-p286" "1.9.3-p327" "1.9.3-p362" "1.9.3-p374" "1.9.3-p385" "1.9.3-p392" "1.9.3-p429")

OLD_VERSIONS=$OLD_VERSIONS CURRENT=$CURRENT LINK=$LINK KEEP=$KEEP debuntu_ruby_rbenv_install_latest
}

function debuntu_ruby_rbenv_install_ruby_2.0.0 {
if [[ -n $HELP ]]; then
cat <<EOF 

  Install latest ruby 2.0.0 and remove all other patcheѕ.
  This version is then kown to rbenv by ruby-2.0.0.
 
  optional vars:

  KEEP (non empty string) will preserve the currently existing if it is up to the lates patchlevel.
EOF
return
fi

CURRENT='2.0.0-p247'
LINK='ruby-2.0.0'
declare -a OLD_VERSIONS=("2.0.0-p0" "2.0.0-p195")

OLD_VERSIONS=$OLD_VERSIONS CURRENT=$CURRENT LINK=$LINK KEEP=$KEEP debuntu_ruby_rbenv_install_latest


}

function debuntu_ruby_rbenv_install_ruby_2.1.0 {
if [[ -n $HELP ]]; then
cat <<EOF 

  Install latest ruby 2.1.0 and remove all other patcheѕ.
  This version is then known to rbenv by ruby-2.1.0.
 
  optional vars:

  KEEP (non empty string) will preserve the currently existing if it is up to the lates patchlevel.
EOF
return
fi

CURRENT='2.1.0'
LINK='ruby-2.1.0'
declare -a OLD_VERSIONS=("asdf.asdfa.fasdf")

OLD_VERSIONS=$OLD_VERSIONS CURRENT=$CURRENT LINK=$LINK KEEP=$KEEP debuntu_ruby_rbenv_install_latest

}

function debuntu_ruby_rbenv_prepare-system {
debuntu_ruby_rbenv_system_install_dependencies 
debuntu_ruby_rbenv_system_setup_loader
}

function debuntu_ruby_rbenv_system_install_dependencies {
case `debuntu_system_meta_os-name` in
  Debian*)
    if [[ ! -f /etc/apt/sources.list.d/backports.list ]]; then
      echo 'deb  http://ftp.ch.debian.org/debian/ wheezy-backports main' > /etc/apt/sources.list.d/backports.list
      apt-get update
    fi
    ;;
esac


apt-get install --assume-yes git zlib1g-dev \
  libssl-dev libxslt1-dev libxml2-dev build-essential \
  libreadline-dev libreadline6 libreadline6-dev g++ \
  nodejs
}

function debuntu_ruby_rbenv_system_setup_loader {
cat <<'HEREDOC0' > /etc/profile.d/rbenv.sh
function load_rbenv {
export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"
eval "$(rbenv init -)"
}
function unload_rbenv(){
export PATH=`ruby -e "puts ENV['PATH'].split(':').reject{|s| s.match(/\.rbenv/)}.join(':')"`
}
HEREDOC0
}

function debuntu_ssh_add_to_authorized_keys {
KEY=$1
echo "adding $KEY"
TMPFILE=`mktemp /tmp/debuntu-XXXXX`
if [ ! -d ~/.ssh ]; then
  mkdir -p ~/.ssh
  chmod go-rwx ~/.ssh
fi
if [ ! -f ~/.ssh/authorized_keys ]; then
  touch ~/.ssh/authorized_keys
  chmod go-rwx ~/.ssh/authorized_keys
fi
echo "$KEY" >> ~/.ssh/authorized_keys;
cat ~/.ssh/authorized_keys | sort | uniq > "$TMPFILE"
cat $TMPFILE > ~/.ssh/authorized_keys
echo "the content of ~/.ssh/authorized_keys is now:" 
echo "=============================================" 
cat ~/.ssh/authorized_keys
}

function debuntu_ssh_download_and_add_to_authorized_keys {
KEY="$(curl $1)"
debuntu_ssh_add_to_authorized_keys "$KEY"
}

function debuntu_ssh_download_and_add_to_authorized_keys_for_user {
# download and adds a ssh-key to authorized key of an existing user 
# first argument is the user, second argument is the url 
USER=$1
URL=$2
TMPFILE=`mktemp`
chown $USER $TMPFILE
read -r -d '' INSTALL_CMD <<HEREDOC0
if [ ! -d ~/.ssh ]; then
  mkdir -p ~/.ssh
  chmod go-rwx ~/.ssh
fi
if [ ! -f ~/.ssh/authorized_keys ]; then
  touch ~/.ssh/authorized_keys
  chmod go-rwx ~/.ssh/authorized_keys
fi
curl -s "${URL}" >> ~/.ssh/authorized_keys;
cat ~/.ssh/authorized_keys | sort | uniq > $TMPFILE
cat $TMPFILE > ~/.ssh/authorized_keys
rm $TMPFILE
HEREDOC0
echo "$INSTALL_CMD" | su -l $USER
rm $TMPFILE
}

function debuntu_system_apt_upgrade {
apg-get update
apt-get dist-upgrade --assume-yes
}

function debuntu_system_install_basics {
apt-get install --assume-yes curl git openssh-server unzip zip lsb-release
}

function debuntu_system_meta_os-name {
echo -ne "$(lsb_release -is)/$(lsb_release -cs)"
}

function debuntu_system_misc_enable_backports {
vim -c "%s/\v^(#+\s+)(deb.*-backports)/\2/g" -c "wq" "/etc/apt/sources.list"
apt-get update
}

function debuntu_system_misc_etckeeper_setup {
apt-get install etckeeper
cat <<'EOF' > "/etc/etckeeper/etckeeper.conf"
VCS="git"
HIGHLEVEL_PACKAGE_MANAGER=apt
LOWLEVEL_PACKAGE_MANAGER=dpkg
EOF

if [ ! -d "/etc/.git" ]; then 
  etckeeper uninit -f
  etckeeper init
  etckeeper commit "initial commit" 
fi 
}

function debuntu_system_misc_set_us-utf8_locale {
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
locale-gen en_US.UTF-8
apt-get install --assume-yes locales
dpkg-reconfigure locales

cat <<HEREDOC0 > /etc/profile.d/locale.sh 
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
HEREDOC0
}

function debuntu_system_misc_setup_init_service {
if [[ -z $DIR || -z $NAME || -z $USER || -z $COMMAND || -n $HELP ]]; then
cat <<EOF 
  Sets up a (rather simple) system service.
  
  Requires the following variables to be set:

  DIR absolute path where to cd before starting the service
  NAME name of the service
  USER the user under which the service will run
  COMMAND the command executed 
EOF
exit 0 # replace with return
fi

ruby <<'EOF'
ENV.each do |k,v|
 puts "#{k}: #{v}"
end
EOF
}

function debuntu_system_misc_setup_logrotate {
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
}

function debuntu_system_misc_setup_service {
# dispatching on debuntu_system_meta_os-name
case `debuntu_system_meta_os-name` in
  Debian*)
    # DIR="$DIR" NAME="$NAME" USER="$USER" COMMAND=$COMMAND debuntu_system_misc_setup_init_service 
    echo "general init scripts on debian are not supported yet"
    ;;
  Ubuntu*)
    DIR="$DIR" NAME="$NAME" USER="$USER" COMMAND=$COMMAND debuntu_system_misc_setup_upstart_service 
    ;;
esac
}

function debuntu_system_misc_setup_upstart_service {
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
}

function debuntu_system_misc_vim_setup {
apt-get install --assume-yes vim-nox
update-alternatives --set editor /usr/bin/vim.nox
}

function debuntu_system_setup {
debuntu_system_apt_upgrade
debuntu_system_misc_set_us-utf8_locale
debuntu_system_install_basics
debuntu_system_misc_vim_setup
debuntu_system_misc_etckeeper_setup
}

function debuntu_zhdk_domina-slave_complete-setup-as-user {
debuntu_zhdk_ssh_add-keys
debuntu_ci_chromedriver_install
debuntu_zhdk_domina-slave_ruby_install
debuntu_ci_phantomjs_install
debuntu_ci_tightvnc_user_setup
}

function debuntu_zhdk_domina-slave_complete-setup {
# domina_ci_executor
debuntu_jvm_open_jdk_install
adduser --disabled-password -gecos "" domina
debuntu_zhdk_domina-slave_domina-ci-executor_setup

# pg
debuntu_database_postgresql_install_9.2
debuntu_database_postgresql_add_superuser domina

# other
debuntu_ci_tightvnc_install
debuntu_ruby_rbenv_prepare-system
debuntu_invoke_as_user domina debuntu_zhdk_domina-slave_complete-setup-as-user
}

function debuntu_zhdk_domina-slave_domina-ci-executor_as-domina-setup {
debuntu_ci_domina-ci-executor_install "6b03ebd632ea31f8f81b157a69834ee5bda9357c"

cat <<'EOF' > ~/domina_ci_executor/domina_conf.clj
{
 :shared { :working-dir "/tmp/domina_working_dir"
           :git-repos-dir "/tmp/domina_git_repos" 
          }

 :reporter {:max-retries 10
            :retry-ms-factor 3000}

 :nrepl {:port 7888
         :bind "0.0.0.0"
         :enabled true}

 :web {:host "0.0.0.0"
       :port 8088
       :ssl-port 8443}
}
EOF

debuntu_jvm_leiningen_install
}

function debuntu_zhdk_domina-slave_domina-ci-executor_setup {
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
}

function debuntu_zhdk_domina-slave_ruby_gherkin_setup_ragel_lexer {
SDIR=$(pwd)
echo Setting up ragle for $RBENV_RUBY_VERSION $GEMS_VERSION $GHERKIN_VERSION
load_rbenv \
&& rbenv rehash \
&& rbenv shell $RBENV_RUBY_VERSION \
&& gem install gherkin -v ${GHERKIN_VERSION} \
&& cd ~/.rbenv/versions/$RBENV_RUBY_VERSION/lib/ruby/gems/${GEMS_VERSION}/gems/gherkin-${GHERKIN_VERSION}/  \
&& bundle install \
&& rbenv rehash \
&& bundle exec rake compile:gherkin_lexer_en \
&& cd "${SDIR}"
}

function debuntu_zhdk_domina-slave_ruby_install {
debuntu_ruby_rbenv_install
KEEP=true debuntu_ruby_rbenv_install_ruby_1.9.3 
KEEP=true debuntu_ruby_rbenv_install_ruby_2.0.0 
KEEP=true debuntu_ruby_rbenv_install_ruby_2.1.0 
RBENV_RUBY_VERSION="ruby-1.9.3" GEMS_VERSION="1.9.1" GHERKIN_VERSION="2.12.0" debuntu_zhdk_domina-slave_ruby_gherkin_setup_ragel_lexer
}

function debuntu_zhdk_ssh_add-keys {
debuntu_ssh_download_and_add_to_authorized_keys "https://raw.github.com/DrTom/debuntu_setup_scripts/master/data/keys/drtom"
debuntu_ssh_download_and_add_to_authorized_keys "https://raw.github.com/DrTom/debuntu_setup_scripts/master/data/keys/nimaai"
debuntu_ssh_download_and_add_to_authorized_keys "https://raw.github.com/DrTom/debuntu_setup_scripts/master/data/keys/psy-q"
debuntu_ssh_download_and_add_to_authorized_keys "https://raw.github.com/DrTom/debuntu_setup_scripts/master/data/keys/sellittf"
debuntu_ssh_download_and_add_to_authorized_keys "https://raw.github.com/DrTom/debuntu_setup_scripts/master/data/keys/spape"
}

