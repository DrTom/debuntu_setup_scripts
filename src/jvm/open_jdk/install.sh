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
