if [[ -n $HELP ]]; then
cat <<EOF 

  Install latest ruby 2.0.0 and remove all other patcheѕ.
  This version is then kown to rbenv by ruby-2.0.0.
 
  optional vars:

  KEEP (non empty string) will preserve the currently existing if it is up to the lates patchlevel.
EOF
return
fi

CURRENT='1.9.3-p448'
LINK='ruby-1.9.3'
declare -a OLD_VERSIONS=("1.9.3-p0" "1.9.3-p125" "1.9.3-p194" "1.9.3-p286" "1.9.3-p327" "1.9.3-p362" "1.9.3-p374" "1.9.3-p385" "1.9.3-p392" "1.9.3-p429")

OLD_VERSIONS=$OLD_VERSIONS CURRENT=$CURRENT LINK=$LINK KEEP=$KEEP debuntu_ruby_rbenv_install_latest
