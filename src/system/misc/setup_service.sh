# dispatching on debuntu_system_meta_os-name
case `debuntu_system_meta_os-name` in
  Debian*)
    # DIR="$DIR" NAME="$NAME" USER="$USER" COMMAND=$COMMAND debuntu_system_misc_setup_init_service 
    echo "general init scripts on debian are not supported yet"
    ;;
  Ubuntu*)
    DIR="$DIR" NAME="$NAME" USER="$USER" COMMAND=$COMMAND debuntu_system_misc_setup_upstart_service 
    ;;
esac
