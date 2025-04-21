#!/bin/bash
# logging the output
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/var/fsinstalllog.out 2>&1
# Apt install the deps:
apt install -y build-essential pkg-config uuid-dev zlib1g-dev libjpeg-dev libsqlite3-dev libcurl4-openssl-dev libpcre3-dev libspeexdsp-dev libldns-dev libedit-dev libtiff5-dev yasm libopus-dev libsndfile1-dev unzip libavformat-dev libswscale-dev liblua5.2-dev liblua5.2-0 cmake libpq-dev unixodbc-dev autoconf automake ntpdate libxml2-dev libpq-dev libpq5 sngrep lua5.2 lua5.2-doc libreadline-dev libshout3-dev ffmpeg libmpg123-dev libmp3lame-dev libhiredis-dev libtool mtr jq


# Install libspandsp3
cd /usr/local/src/ && git clone https://github.com/freeswitch/spandsp.git
# https://github.com/signalwire/freeswitch/issues/2184 for below commit
cd spandsp/ && git checkout 0d2e6ac
./bootstrap.sh && ./configure && make && make install

# Install sofia-sip
cd /usr/local/src/ && wget "https://github.com/freeswitch/sofia-sip/archive/master.tar.gz" -O sofia-sip.tar.gz
tar -xvf sofia-sip.tar.gz
cd sofia-sip-master && ./bootstrap.sh && ./configure && make && make install
sleep 10
# Download FreeSWITCH
cd /usr/local/src/ && wget https://files.freeswitch.org/releases/freeswitch/freeswitch-1.10.12.-release.tar.gz
tar -zxvf freeswitch-1.10.12.-release.tar.gz
cd freeswitch-1.10.12.-release
# sed commands here to comment out and uncomment certain modules for our use. Using sleep as interactively changing the file multiplt times breaks the script. 
sed -i 's/#applications\/mod\_curl/applications\/mod\_curl/g' /usr/local/src/freeswitch-1.10.12.-release/modules.conf
sleep 1
sed -i 's/#applications\/mod\_hiredis/applications\/mod\_hiredis/g' /usr/local/src/freeswitch-1.10.12.-release/modules.conf
sleep 1
sed -i 's/#formats\/mod\_shout/formats\/mod\_shout/g' /usr/local/src/freeswitch-1.10.12.-release/modules.conf
sleep 1
sed -i 's/applications\/mod\_signalwire/#applications\/mod\_signalwire/g' /usr/local/src/freeswitch-1.10.12.-release/modules.conf
sleep 1
sed -i 's/endpoints\/mod\_verto/#endpoints\/mod\_verto/g' /usr/local/src/freeswitch-1.10.12.-release/modules.conf
sleep 1
sudo ./configure 
sleep 10
sudo make && sudo make install 
sleep 10
make cd-sounds-install && make cd-moh-install
sleep 10 
sudo ln -s /usr/local/freeswitch/conf /etc/freeswitch
sudo ln -s /usr/local/freeswitch/bin/fs_cli /usr/bin/fs_cli
sudo ln -s /usr/local/freeswitch/bin/freeswitch /usr/sbin/freeswitch

sudo ln -s /usr/local/lib/libspandsp.so.3.0.0 /usr/local/freeswitch/bin/libspandsp.so.3.0.0
sudo ln -s /usr/local/lib/libspandsp.so.3 /usr/local/freeswitch/bin/libspandsp.so.3
sudo ln -s /usr/local/lib/libspandsp.so /usr/local/freeswitch/bin/libspandsp.so
mkdir /var/log/freeswitch/
mkdir /var/run/freeswitch/
ldconfig && ldconfig -p
# Adding user - done in salt already
groupadd freeswitch 
adduser --quiet --system --home /usr/local/freeswitch --gecos 'FreeSWITCH open source softswitch' --ingroup freeswitch freeswitch --disabled-password
chown -R freeswitch:freeswitch /usr/local/freeswitch/ 
chmod -R ug=rwX,o= /usr/local/freeswitch/ 
chmod -R u=rwx,g=rx /usr/local/freeswitch/bin/*

# ldconfig && ldconfig -p | grep spandsp
# had to enable/start the service once the  - then reboot again
# Just ran fs_cli after the box came back up.