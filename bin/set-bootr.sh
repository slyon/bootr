#!/bin/sh
mount -o remount,rw /
cd /sbin
busybox ln -sf init.bootr init
cd ..

# for Palm Pre, Pre Plus, Pre 2
if [ -e uImage-2.6.24-palm-joplin-3430 ]; then
    busybox ln -sf uImage-2.6.24-palm-joplin-3430 uImage
# for HP Pre 3
elif [ -e uImage-2.6.32.9-palm-rib ]; then
    busybox ln -sf uImage-2.6.32.9-palm-rib uImage
# for HP Veer
elif [ -e uImage-2.6.29-palm-shank ]; then
    busybox ln -sf uImage-2.6.29-palm-shank uImage
# for HP TouchPad Go
elif [ -e uImage-2.6.35-palm-shortloin ]; then
    busybox ln -sf uImage-2.6.35-palm-shortloin uImage
# for HP TouchPad
else
    busybox ln -sf uImage-2.6.35-palm-tenderloin uImage
fi
busybox sync

