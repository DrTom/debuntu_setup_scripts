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
