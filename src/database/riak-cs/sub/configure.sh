
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

curl "https://raw.githubusercontent.com/DrTom/debuntu_setup_scripts/master/data/riak-cs-config.patch" | git apply --directory /etc

etckeeper commit "Configured riak-cs"

/etc/init.d/riak start
/etc/init.d/stanchion start
/etc/init.d/riak-cs start
sleep 3
