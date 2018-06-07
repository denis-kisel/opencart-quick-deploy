# opencart-testplace
Rapid deployment of all versions of opencart for testing extensions

# install
$ cd /path/to/root-server-directory

$ git clone https://github.com/denis-kisel/opencart-testplace oc.testplace

# settings

$ cd oc.tesplace

Change configs for your environtment:

$ nano init.sh

Init/update projects:

$ ./init.sh #Will create all versions of opencart

$ ./init.sh 2000 2200 3000 #Will create the specified versions of opencart

# test
Open the link http://yourhost/oc.testplace/ in your browser and select version
