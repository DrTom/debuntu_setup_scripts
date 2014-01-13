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
