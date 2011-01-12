#!/bin/sh

# Switch to miniboot
sh /boot/bootr/bin/init.sh
# Default OS
# alternatives: 'webos', 'shr'
OS='webos'

if [[ $OS == 'shr'  ]]
then
    bzcat /boot/bootr/data/shr.fbz > /dev/fb0
else
    bzcat /boot/bootr/data/webos.fbz > /dev/fb0
fi

while true;
    do
    event=`hexdump -e '1/1 "%.2x"' /dev/input/event1 -n 16`

    #Power Button Released
    #FIXME: this is ugly
    if [[ `echo $event | sed 's/^.*006b0.*$/true/g'` == 'true'  ]]
    then
        bzcat /boot/bootr/data/booting.fbz > /dev/fb0
        mount -o remount,rw /boot
        cd /boot/sbin

        if [[ $OS == 'shr' ]]
        then
            ln -sf init.fso.bootr init
            cd ..
            ln -sf uImage-palmpre.bin uImage
        else
            ln -sf init.webos.bootr init
            cd ..
            ln -sf uImage-2.6.24-palm-joplin-3430 uImage
        fi
        tellbootie
        break
    fi

    #VolumeUp Button Released
    #FIXME: this is ugly
    if [[ `echo $event | sed 's/^.*00730.*$/true/g'` == 'true'  ]]
    then
        bzcat /boot/bootr/data/webos.fbz > /dev/fb0
        OS='webos'
        continue
    fi

    #VolumeDown Button Released
    #FIXME: this is ugly
    if [[ `echo $event | sed 's/^.*00720.*$/true/g'` == 'true'  ]]
    then
        bzcat /boot/bootr/data/shr.fbz > /dev/fb0
        OS='shr'
        continue
    fi
    done
exit 0
