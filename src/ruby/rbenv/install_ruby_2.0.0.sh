if [[ -n $HELP ]]; then
cat <<EOF 

  Install latest ruby 2.0.0 and remove all other patcheѕ.
  This version is then kown to rbenv by ruby-2.0.0.
 
  optional vars:

  KEEP (non empty string) will preserve the currently existing if it is up to the lates patchlevel.
EOF
return
fi

CURRENT='2.0.0-p247'
LINK='ruby-2.0.0'
declare -a OLD_VERSIONS=("2.0.0-p0" "2.0.0-p195")

OLD_VERSIONS=$OLD_VERSIONS CURRENT=$CURRENT LINK=$LINK KEEP=$KEEP debuntu_ruby_rbenv_install_latest


