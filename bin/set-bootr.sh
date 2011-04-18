#!/bin/sh
mount -o remount,rw /
cd /sbin
busybox ln -sf init.bootr init
cd ..
busybox ln -sf uImage-2.6.24-palm-joplin-3430 uImage
busybox sync

