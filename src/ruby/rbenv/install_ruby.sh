if [[ -z $VERSION || -n $HELP ]]; then
cat <<EOF 
  
  Install a ruby version. 
  
  required vars: 

    VERSION 

    e.g. VERSION='2.0.0-p247'

  optional vars: 

    LINK

    e.g. LINK='ruby-2.0.0'
EOF
return 
fi


source /etc/profile.d/rbenv.sh
load_rbenv;
rbenv install -f $VERSION;
rbenv shell $VERSION;
rbenv rehash;
gem update --system;
gem install rubygems-update;
gem install bundler;
rbenv rehash;

if [[ -n $LINK ]]; then 
  rm -f ~/.rbenv/versions/$LINK;
  ln -s  ~/.rbenv/versions/$VERSION/ ~/.rbenv/versions/$LINK;
fi

