if [[ -n $HELP ]]; then
cat <<EOF 

  Install latest jruby 1.7 and remove all older 1.7 versions
  This version is then kown to rbenv by jruby-1.7
 
  optional vars:

  KEEP (non empty string) will preserve the currently existing if it is up to the lates patchlevel.
EOF
return
fi

CURRENT='jruby-1.7.9'
LINK='jruby-1.7'
declare -a OLD_VERSIONS=("jruby-1.7.4" "jruby-1.7.5")

OLD_VERSIONS=$OLD_VERSIONS CURRENT=$CURRENT LINK=$LINK KEEP=$KEEP debuntu_ruby_rbenv_install_latest
