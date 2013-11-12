mkdir -p ~/bin
MACHINE=`uname -m`
TMDIR=`mktemp -d`
cd $TMPDIR
curl "https://phantomjs.googlecode.com/files/phantomjs-1.9.0-linux-${MACHINE}.tar.bz2" | tar xj
cp phantomjs-1.9.0-linux-x86_64/bin/phantomjs ~/bin/
cd
rm -rf $TMPDIR
