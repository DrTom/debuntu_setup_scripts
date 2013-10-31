if [[ -z $LINK || -z $CURRENT || -z ${OLD_VERSIONS} || -n $HELP ]]; then
cat <<EOF 

  required vars: 

  OLD_VERSIONS ($OLD_VERSION)
  CURRENT ($CURRENT)
  LINK ($LINK)

  optional vars:

  KEEP

EOF
return
fi

VERSIONS_DIR="${HOME}"/.rbenv/versions

for V in ${OLD_VERSIONS[@]}; do
  echo "removing $V if exists"
  rm -rf  "$VERSIONS_DIR"/"${V}"
done 


if [[ -n $KEEP ]]; then
  echo "keeping current if exists; checking $VERSIONS_DIR/$CURRENT"
  if [ ! -d "$VERSIONS_DIR/$CURRENT" ]; then
    echo "did not found existing $CURRENT ruby, installing ... " 
    VERSION=$CURRENT LINK=$LINK debuntu_ruby_rbenv_install_ruby 
  else
    echo "found existing $CURRENT ruby, done." 
  fi
else
  echo "forcing reinstall"
  rm -rf "$VERSIONS_DIR"/"$CURRENT"
  VERSION=$CURRENT LINK=$LINK debuntu_ruby_rbenv_install_ruby 
fi

