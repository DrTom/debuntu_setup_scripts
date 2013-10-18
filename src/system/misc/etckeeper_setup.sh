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
