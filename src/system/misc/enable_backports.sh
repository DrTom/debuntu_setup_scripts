vim -c "%s/\v^(#+\s+)(deb.*-backports)/\2/g" -c "wq" "/etc/apt/sources.list"
apt-get update
