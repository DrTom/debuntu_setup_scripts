TMDIR=`mktemp -d`
cd $TMDIR
MACHINE_BITS=`uname -m | cut -d '_' -f 2`
curl -s -L "http://chromedriver.storage.googleapis.com/2.8/chromedriver_linux${MACHINE_BITS}.zip" > chromedriver.zip
unzip chromedriver.zip
mv chromedriver ~/bin
cd
rm -rf $TMDIR
