#!/bin/sh
mount -o remount,rw /boot
OS="Bootr"
cd /boot/sbin
if [ "$1" = "webos" ]; then
	ln -sf /sbin/init.webos.bootr init
	cd /boot
	ln -sf /uImage-2.6.24-palm-joplin-3430 uImage
	OS="WebOS"
fi
if [ "$1" = "shr" ]; then
	ln -sf /sbin/init.fso.bootr init
	cd /boot
	ln -sf /uImage-palmpre.bin uImage
	OS="SHR"
fi
echo "Rebooting into $OS"
tellbootie
