#!/bin/sh
mount -o remount,rw /
cd /sbin
busybox ln -sf init.bootr init
cd ..

# for palm pre, preplus, pre2
if [ -e uImage-2.6.24-palm-joplin-3430 ]; then
    busybox ln -sf uImage-2.6.24-palm-joplin-3430 uImage
# for palm pre3
elif [ -e uImage-2.6.32.9-palm-rib ]; then
    busybox ln -sf uImage-2.6.32.9-palm-rib uImage
# for touchpad
else
    busybox ln -sf uImage-2.6.35-palm-tenderloin uImage
fi
busybox sync

