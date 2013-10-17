apt-get install --assume-yes openjdk-7-jre-headless openjdk-7-jdk

# Ugly hack: visualvm is packaged for Debian testing (jessie), not for wheezy, so
# let's not attempt to install there.
if debuntu_system_is_ubuntu; then
        apt-get install --assume-yes visualvm
fi
