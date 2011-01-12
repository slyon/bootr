#!/bin/sh

if [[ $1 == 'install' ]]
then
	#doit
	echo 'Doing it...'
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
