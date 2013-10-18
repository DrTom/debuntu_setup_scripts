function debuntu_ci_chromedriver_install {
TMDIR=`mktemp -d`
cd $TMDIR
MACHINE_BITS=`uname -m | cut -d '_' -f 2`
curl -s -L "http://chromedriver.storage.googleapis.com/2.4/chromedriver_linux${MACHINE_BITS}.zip" > chromedriver.zip
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
mkdir ~/bin
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
mkdir ~/.vnc
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
if [ -n $2 ]; then
  PG_PW="$2"
else
  PG_PW="$1"
fi
cat << HEREDOC0 | su -l postgres -c psql
CREATE USER $PG_USER superuser createdb login;
ALTER USER $PG_USER WITH PASSWORD '$PG_PW';
CREATE DATABASE $PG_USER ;
GRANT ALL ON DATABASE $PG_USER TO $PG_USER;
HEREDOC0
}

function debuntu_database_postgresql_install_9.2 {
debuntu_database_postgresql_add_pgdg_apt_repository
apt-get install --assume-yes postgresql-9.2 postgresql-client-9.2 postgresql-contrib-9.2 postgresql-server-dev-9.2
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

function debuntu_rails-server_setup-as-torquebox {
debuntu_ruby_rbenv_install
debuntu_ruby_rbenv_install_ruby_2.0.0
}

function debuntu_rails-server_setup {
debuntu_torquebox_install_3.0.0
debuntu_database_postgresql_install_9.2
debuntu_database_postgresql_add_superuser torquebox
debuntu_invoke_as_user torquebox debuntu_rails-server_setup-as-torquebox
}

function debuntu_ruby_rbenv_install {
curl https://raw.github.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash
}

function debuntu_ruby_rbenv_install_jruby_1.7.4 {
RUBY='jruby-1.7.4'
debuntu_ruby_rbenv_install_ruby "$RUBY" "$LINK"
}

function debuntu_ruby_rbenv_install_ruby {
RUBY=$1

source /etc/profile.d/rbenv.sh
load_rbenv;
rbenv install -f $RUBY;
rbenv shell $RUBY;
rbenv rehash;
gem update --system;
gem install rubygems-update;
update_rubygems;
gem install bundler;
rbenv rehash;

if [ -n "$2" ]; then 
  LINK=$2
  rm -f ~/.rbenv/versions/$LINK;
  ln -s  ~/.rbenv/versions/$RUBY/ ~/.rbenv/versions/$LINK;
fi
}

function debuntu_ruby_rbenv_install_ruby_1.9.3 {
# $1 == KEEP ; do not force to reinstall from scratch
# $2 == REMOVE-PREVIOUS ; remove all previous patch versions

CURRENT='1.9.3-p448'
LINK='ruby-1.9.3'
declare -a OLD_VERSIONS=("1.9.3-p0" "1.9.3-p125" "1.9.3-p194"  \
    "1.9.3-p286" "1.9.3-p327" "1.9.3-p362" "1.9.3-p374" "1.9.3-p385" \
    "1.9.3-p392" "1.9.3-p429")

VERSIONS_DIR="${HOME}"/.rbenv/versions

echo $1
echo $2

if [ "$1" == "KEEP" ]; then
  if [ ! -d "${VERSIONS_DIR}/${CURRENT}" ]; then
     debuntu_ruby_rbenv_install_ruby "$CURRENT" "$LINK"
   else
     echo "Found and keeping ${CURRENT}"
  fi
else
  rm -rf "${VERSIONS_DIR}/${CURRENT}"
  debuntu_ruby_rbenv_install_ruby "$CURRENT" "$LINK"
fi

if [ "$2" == "REMOVE-PREVIOUS" ]; then
  for V in ${OLD_VERSIONS[@]}; do
    if [ ! -d "${VERSIONS_DIR}/${V}" ]; then
      echo "removing $V"
      rm -rf  "$VERSIONS_DIR"/"${V}"
    fi
  done 
fi 

}

function debuntu_ruby_rbenv_install_ruby_2.0.0 {
#!/bin/bash

# $1 == KEEP ; do not force to reinstall from scratch
# $2 == REMOVE-PREVIOUS ; remove all previous patch versions

CURRENT='2.0.0-p247'
LINK='ruby-2.0.0'
declare -a OLD_VERSIONS=("2.0.0-p0" "2.0.0-p195")

VESIONS_DIR="${HOME}"/.rbenv/versions

if [ "$2" == "REMOVE-PREVIOUS" ]; then
  for V in ${OLD_VERSIONS[@]}; do
    removing $V
    rm -rf  "$VERSIONS"/"${V}"
  done 
fi 

if [ "$1" == "KEEP" ]; then
  if [ ! -d "$VERSIONS"/"$CURRENT" ]; then
    debuntu_ruby_rbenv_install_ruby "$CURRENT" "$LINK"
  fi
else
  rm -rf "$VERSIONS"/"$CURRENT"
  debuntu_ruby_rbenv_install_ruby "$CURRENT" "$LINK"
fi
}

function debuntu_ruby_rbenv_install_system_dependencies {
apt-get install --assume-yes git zlib1g-dev \
  libssl-dev libxslt1-dev libxml2-dev build-essential \
  libreadline-dev libreadline6 libreadline6-dev g++
}

function debuntu_ruby_rbenv_setup_loader_function {
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

function debuntu_torquebox_install_3.0.0 {
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
mkdir $LOGDIR
chown -R torquebox $LOGDIR

debuntu_torquebox_setup_env_loader
debuntu_torquebox_setup_logrotate
debuntu_torquebox_setup_start_stop_scripts

service torquebox start
}

function debuntu_torquebox_setup_env_loader {
cat <<'HEREDOC0' > /etc/profile.d/torquebox.sh
function load_torquebox_env {
export JRUBY_OPTS="--1.9"
export JAVA_OPTS="-server -Xms64m -Xmx2G -XX:MaxPermSize=512m"
export JAVA_OPTS="$JAVA_OPTS -Djava.net.preferIPv4Stack=true -Dorg.jboss.resolver.warning=true"
export JAVA_OPTS="$JAVA_OPTS -Dsun.rmi.dgc.client.gcInterval=3600000 -Dsun.rmi.dgc.server.gcInterval=3600000"
export JAVA_OPTS="$JAVA_OPTS -Djboss.modules.system.pkgs=$JBOSS_MODULES_SYSTEM_PKGS -Djava.awt.headless=true"
export JAVA_OPTS="$JAVA_OPTS -Djboss.server.default.config=standalone.xml"
export TORQUEBOX_HOME=/opt/torquebox
export JBOSS_HOME=${TORQUEBOX_HOME}/jboss
export JRUBY_HOME=${TORQUEBOX_HOME}/jruby
export PATH=${TORQUEBOX_HOME}/bin:${JBOSS_HOME}/bin:${JRUBY_HOME}/bin:${PATH}
}
HEREDOC0


}

function debuntu_torquebox_setup_init {
cat <<'HEREDOC0' > /etc/init.d/torquebox
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
# Provides:          torquebox
# Required-Start:    $network $local_fs
# Required-Stop:
# Should-Start:      $named
# Should-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Torquebox Application Server
# Description:       A JRuby application server based on JBoss AS 7 
### END INIT INFO

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

. /lib/lsb/init-functions

source /etc/profile.d/torquebox.sh
load_torquebox_env

TORQUEBOX_SERVER=standalone.xml
RUN=yes

NAME=torquebox
DESC="Torquebox Application Server"
LOGDIR=/var/log/$NAME
LOGFILE=$LOGDIR/$NAME.log
PIDFILE=/var/run/$NAME.pid
DIETIME=15
STARTTIME=10
DAEMONUSER=torquebox

#TORQUEBOX_HOME=/usr/share/$NAME
# . /etc/default/$NAME || exit 1

TORQUEBOX_START="$TORQUEBOX_HOME/jboss/bin/standalone.sh"
TORQUEBOX_STOP="$TORQUEBOX_HOME/jboss/bin/jboss-cli.sh --connect command=:shutdown"


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
  PID=`ps -fu torquebox | grep jboss-modules.jar | grep -v grep | awk {'print $2'}`
  if [[ -f /proc/$PID/cmdline && -n $PID ]] ; then
    return 0
  else
    return 1
  fi
}

start_server() {
  echo "`date`: Starting $DESC: $TORQUEBOX_SERVER" >> $LOGFILE
  log_progress_msg "(this will take $STARTTIME seconds) "
  start-stop-daemon --start --quiet --chuid $DAEMONUSER  \
    --exec $TORQUEBOX_START --pidfile $PIDFILE --make-pidfile -- -c $TORQUEBOX_SERVER >> $LOGFILE 2>&1 &
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
  echo "`date`: Stopping $DESC: $TORQUEBOX_SERVER" >> $LOGFILE
  log_progress_msg "(this will take $DIETIME seconds) "
  $TORQUEBOX_STOP >> $LOGFILE 2>&1
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
  pkill -u torquebox >> $LOGFILE
  sleep $DIETIME
  if running ; then
    echo "`date`: Stopping (force) $NAME with pkill -9" >> $LOGFILE
    pkill -9 -u torquebox >> $LOGFILE
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
    log_begin_msg "Starting $DESC: $TORQUEBOX_SERVER "
    if running ; then
      echo "`date`: $NAME running, therefore not trying to start" >> $LOGFILE
      log_success_msg "- apparently already running"
    else
      start_server
    fi
    ;;

  stop)
    if [ $TORQUEBOX_SERVER == "minimal" ] || [ $TORQUEBOX_SERVER == "web" ] ; then
      $0 force-stop
    else
      log_begin_msg "Stopping $DESC: $TORQUEBOX_SERVER "
      if running ; then
        stop_server
      else
        echo "`date`: $NAME not running, therefore not trying to stop" >> $LOGFILE
        log_success_msg "- apparently not running"
      fi
    fi
    ;;

  force-stop)
    log_begin_msg "Force-stopping $DESC: $TORQUEBOX_SERVER "
    if running ; then
      force_stop_server
    else
      echo "`date`: $NAME not running, therefore not trying to stop" >> $LOGFILE
      log_success_msg "- apparently not running"
    fi
    ;;

  restart|force-reload)
    if [ $TORQUEBOX_SERVER == "minimal" ] || [ $TORQUEBOX_SERVER == "web" ] ; then
      log_begin_msg "Force-stopping $DESC: $TORQUEBOX_SERVER "
      if running ; then
        force_stop_server
      else
        echo "`date`: $NAME not running, therefore not trying to stop" >> $LOGFILE
        log_warning_msg "- apparently not running"
        exit 0
      fi
    else
      log_begin_msg "Stopping $DESC: $TORQUEBOX_SERVER "
      if running ; then
        stop_server
      else
        echo "`date`: $NAME not running, therefore not trying to stop" >> $LOGFILE
        log_warning_msg "- apparently not running"
        exit 0
      fi
    fi
    log_begin_msg "Starting $DESC: $TORQUEBOX_SERVER "
    if running ; then
      echo "`date`: $NAME running, therefore not trying to start" >> $LOGFILE
      log_success_msg "- apparently already running"
    else
      start_server
    fi
    ;;

  status)
    log_begin_msg "Checking status of $DESC: $TORQUEBOX_SERVER "
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

chmod a+x /etc/init.d/torquebox
}

function debuntu_torquebox_setup_logrotate {
cat <<'HEREDOC0' > /etc/logrotate.d/torquebox
/var/log/torquebox/*.log  /opt/torquebox/jboss/standalone/log/*/*.log /home/torquebox/*/log/*.log {
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
logrotate -d -v /etc/logrotate.d/torquebox
}

function debuntu_torquebox_setup_start_stop_scripts {
case `debuntu_system_meta_os-name` in
  Debian*)
    debuntu_torquebox_setup_init
    ;;
  Ubuntu*)
    debuntu_torquebox_setup_upstart
    ;;
esac
}

function debuntu_torquebox_setup_upstart {
cat <<'HEREDOC0' > /etc/init/torquebox.conf
description "This is an upstart job file for TorqueBox"

pre-start script
bash << "EOF"
  mkdir -p /var/log/torquebox
  chown -R torquebox /var/log/torquebox
EOF
end script

start on filesystem and net-device-up IFACE!=eth0
stop on stopped network-services
respawn
limit nofile 4096 4096

script
bash << "EOF"
  su - torquebox
  load_torquebox_env
  /opt/torquebox/jboss/bin/standalone.sh >> /var/log/torquebox/torquebox.log 2>&1
EOF
end script
HEREDOC0
}

function debuntu_torquebox_uninstall_all {
# this will uninstall all torquebox instances
# but it will leave the torquebox user account
stop torquebox
killall torquebox
killall -9 torquebox
rm -rf /opt/torquebox*
rm -f /etc/init/torquebox.conf
}

function debuntu_zhdk_ci_ruby_gherkin_setup_ragel_lexer {
RBENV_RUBY_VERSION=${1:-"ruby-2.0.0"}
GEMS_VERSION=${2:-"2.0.0"}
GHERKIN_VERSION=${3:-"2.12.0"}
SDIR=$(pwd)
echo Setting up ragle for $RBENV_RUBY_VERSION $GEMS_VERSION $GHERKIN_VERSION
load_rbenv \
&& rbenv shell $RBENV_RUBY_VERSION \
&& gem install gherkin -v ${GHERKIN_VERSION} \
&& cd ~/.rbenv/versions/$RBENV_RUBY_VERSION/lib/ruby/gems/${GEMS_VERSION}/gems/gherkin-${GHERKIN_VERSION}/  \
&& bundle install \
&& rbenv rehash \
&& bundle exec rake compile:gherkin_lexer_en \
&& cd "${SDIR}"
}

function debuntu_zhdk_ci_ruby_install {
debuntu_ruby_rbenv_install
debuntu_ruby_rbenv_install_ruby_1.9.3 KEEP REMOVE-PREVIOUS
debuntu_zhdk_ci_ruby_gherkin_setup_ragel_lexer "ruby-1.9.3" "1.9.1" "2.12.0"
}

function debuntu_zhdk_complete-setup-as-user {
debuntu_zhdk_ssh_add-keys
debuntu_ci_chromedriver_install
debuntu_zhdk_ci_ruby_install
debuntu_ci_phantomjs_install
debuntu_ci_tightvnc_user_setup
}

function debuntu_zhdk_complete-setup {
# domina_ci_executor
debuntu_jvm_open_jdk_install
adduser --disabled-password -gecos "" domina
debuntu_zhdk_domina-ci-executor_setup

# pg
debuntu_database_postgresql_install_9.2
debuntu_database_postgresql_add_superuser domina

debuntu_ci_tightvnc_install
debuntu_invoke_as_user domina debuntu_zhdk_complete-setup-as-user
}

function debuntu_zhdk_domina-ci-executor_as-domina-setup {
debuntu_ci_domina-ci-executor_install "0.6.1"

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

function debuntu_zhdk_domina-ci-executor_setup {
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
}

function debuntu_zhdk_ssh_add-keys {
debuntu_ssh_download_and_add_to_authorized_keys "https://raw.github.com/DrTom/debuntu_setup_scripts/master/data/keys/drtom"
debuntu_ssh_download_and_add_to_authorized_keys "https://raw.github.com/DrTom/debuntu_setup_scripts/master/data/keys/nimaai"
debuntu_ssh_download_and_add_to_authorized_keys "https://raw.github.com/DrTom/debuntu_setup_scripts/master/data/keys/psy-q"
debuntu_ssh_download_and_add_to_authorized_keys "https://raw.github.com/DrTom/debuntu_setup_scripts/master/data/keys/sellittf"
debuntu_ssh_download_and_add_to_authorized_keys "https://raw.github.com/DrTom/debuntu_setup_scripts/master/data/keys/spape"
}

