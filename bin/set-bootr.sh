#!/bin/sh
mount -o remount,rw /
busybox ln -sf /sbin/init.bootr /sbin/init
busybox ln -sf /uImage-2.6.24-palm-joplin-3430 /uImage
