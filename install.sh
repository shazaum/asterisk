#!/bin/bash

mkdir /opt/asterisk1/ /opt/asterisk2/

apt-get install -y wget make gcc g++ bzip2 patch libedit-dev uuid-dev libjansson-dev libxml2-dev libsqlite3-dev file
wget https://downloads.asterisk.org/pub/telephony/asterisk/asterisk-16-current.tar.gz
tar zxf asterisk-16-current.tar.gz

cd asterisk-16.3.0
./configure --prefix=/opt/asterisk1 --exec-prefix=/opt/asterisk1 --with-jansson-bundled
make menuselect.makeopts
make
make install
make samples

./configure --prefix=/opt/asterisk2 --exec-prefix=/opt/asterisk2 --with-jansson-bundled
make menuselect.makeopts
make
make install
make samples

adduser --system --shell /bin/false --no-create-home asterisk
usermod -g asterisk asterisk


echo "[Unit]
Description=Asterisk PBX and telephony daemon.
After=network.target

[Service]
Type=notify
Environment=HOME=/opt/asterisk1/var/lib/asterisk
WorkingDirectory=/opt/asterisk1/var/lib/asterisk
User=asterisk
Group=asterisk
ExecStart=/opt/asterisk1/sbin/asterisk -mqf -C /opt/asterisk1/etc/asterisk/asterisk.conf
ExecReload=/opt/asterisk1/sbin/asterisk -rx 'core reload'

#Nice=0
#UMask=0002
LimitCORE=infinity
#LimitNOFILE=
Restart=always
RestartSec=4

# Prevent duplication of logs with color codes to /opt/asterisk1/var/log/messages
StandardOutput=null

PrivateTmp=true

[Install]
WantedBy=multi-user.target
" > /lib/systemd/system/asterisk1.service
systemctl enable asterisk1.service

echo "[Unit]
Description=Asterisk PBX and telephony daemon.
After=network.target

[Service]
Type=notify
Environment=HOME=/opt/asterisk2/var/lib/asterisk
WorkingDirectory=/opt/asterisk2/var/lib/asterisk
User=asterisk
Group=asterisk
ExecStart=/opt/asterisk2/sbin/asterisk -mqf -C /opt/asterisk2/etc/asterisk/asterisk.conf
ExecReload=/opt/asterisk2/sbin/asterisk -rx 'core reload'

#Nice=0
#UMask=0002
LimitCORE=infinity
#LimitNOFILE=
Restart=always
RestartSec=4

# Prevent duplication of logs with color codes to /opt/asterisk2/var/log/messages
StandardOutput=null

PrivateTmp=true

[Install]
WantedBy=multi-user.target
" > /lib/systemd/system/asterisk2.service
systemctl enable asterisk2.service

