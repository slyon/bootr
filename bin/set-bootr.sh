#!/bin/sh
mount -o remount,rw /
cd /sbin
busybox ln -sf init.bootr init
cd ..

if [ -e uImage-2.6.24-palm-joplin-3430 ]; then
    busybox ln -sf uImage-2.6.24-palm-joplin-3430 uImage
else
    busybox ln -sf uImage-2.6.35-palm-tenderloin uImage
fi
busybox sync

