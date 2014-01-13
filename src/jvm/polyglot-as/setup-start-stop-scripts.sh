case `debuntu_system_meta_os-name` in
  Debian*)
    debuntu_jvm_polyglot-as_setup-init
    ;;
  Ubuntu*)
    debuntu_jvm_polyglot-as_setup-upstart
    ;;
esac
