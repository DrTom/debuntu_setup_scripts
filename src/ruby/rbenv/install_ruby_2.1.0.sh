if [[ -n $HELP ]]; then
cat <<EOF 

  Install latest ruby 2.1.0 and remove all other patcheѕ.
  This version is then known to rbenv by ruby-2.1.0.
 
  optional vars:

  KEEP (non empty string) will preserve the currently existing if it is up to the lates patchlevel.
EOF
return
fi

CURRENT='2.1.0'
LINK='ruby-2.1.0'
declare -a OLD_VERSIONS=("asdf.asdfa.fasdf")

OLD_VERSIONS=$OLD_VERSIONS CURRENT=$CURRENT LINK=$LINK KEEP=$KEEP debuntu_ruby_rbenv_install_latest

