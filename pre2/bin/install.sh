#!/bin/sh

if [[ $1 == 'install' ]]
then
	mount -o remount,rw /boot
	echo 'Backing up /boot/sbin/init to /boot/sbin/init.backup.bootr'
	if [[ -x /boot/sbin/init.backup.bootr ]]
	then
		echo '  [OK] Backup already exists.'
	else
		mv /boot/sbin/init /boot/sbin/init.backup.bootr
		echo '  [OK] Saved /boot/sbin/init.backup.bootr'
	fi
	echo 'Copying bootscripts'
	cp /boot/bootr/bootscripts/init.bootr /boot/sbin
	echo '  [OK] Saved /boot/sbin/init.bootr'
	cp /boot/bootr/bootscripts/init.webos.bootr /boot/sbin
	echo '  [OK] Saved /boot/sbin/init.webos.bootr'
	cp /boot/bootr/bootscripts/init.fso.bootr /boot/sbin
	echo '  [OK] Saved /boot/sbin/init.fso.bootr'
	echo 'Installing Bootr'
	cd /boot/sbin
	ln -sf init.bootr init
    sync
	echo '  [OK] Linked init -> init.bootr'
	mount -o remount,ro /boot
	echo 'Done. You can now reboot into Bootr.'
else
	echo ''
	echo '  *** This Script will install Bootr to your Palm Pre ***'
	echo ''
	echo '  * Requirements'
	echo '    WebOS is installed on /dev/mapper/store-root'
	echo '    SHR is installed on /dev/mapper/store-fso'
	echo '    WebOS kernel is at /boot/uImage-2.6.24-palm-joplin-3430'
	echo '    SHR kernel is at /boot/uImage-palmpre.bin'
	echo ''
	echo '  If you really want to install Bootr to /boot/bootr now,'
	echo '  run this script wit the "install" argument:'
	echo '  sh install.sh install'
	echo ''
fi
