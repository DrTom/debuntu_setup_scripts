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
