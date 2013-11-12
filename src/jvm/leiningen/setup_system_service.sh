if [[ -z $DIR || -z $NAME || -z $USER || -n $HELP ]]; then
cat <<EOF 
  Installs a clojure/leinigen project as a systems service.
  
  Requires the following variables to be set:

  DIR absolute path to the leiningen project
  NAME name of the service
  USER the user under which the service will run
EOF

else 


DIR="$DIR" NAME="$NAME" USER="$USER" COMMAND="lein trampoline run" debuntu_system_misc_setup_upstart_service 


fi  
