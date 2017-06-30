#!/usr/bin/env bash

if [[ $UID -ne 0 ]]; then
	echo "This script requires root permission!"
	exit
fi

packages=(squid3 squidguard)

# TODO: need fix package install detection, current method
# will fail if package was installed and then removed.
for pkg in ${packages[@]}; do
	ret=$(dpkg -S $pkg >/dev/null 2>&1; echo $?)
	if [[ $ret -ne 0 ]]; then
		apt-get install -y $pkg
	fi
done

BASEDIR=$(dirname $0)
echo $BASEDIR

cp ${BASEDIR}/etc/squidguard/squidGuard.conf /etc/squidguard/
cp -R ${BASEDIR}/var/lib/squidguard/db /var/lib/squidguard/
cp ${BASEDIR}/etc/squid3/squid.conf /etc/squid3/

# Compile database
/usr/bin/squidGuard -C all

# Permission is important here.
chown -R proxy:proxy /etc/squidguard
chown -R proxy:proxy /var/lib/squidguard/db
chown -R proxy:proxy /var/log/squidguard
chown -R proxy:proxy /usr/bin/squidGuard
chmod -R 755 /var/lib/squidguard/db

echo "Restart squid3 ..."
service squid3 restart
