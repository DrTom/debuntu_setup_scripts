curl http://apt.basho.com/gpg/basho.apt.key | apt-key add -

cat > /etc/apt/sources.list.d/basho.list <<EOF
deb http://apt.basho.com $(lsb_release -sc) main 
EOF

apt-get update
