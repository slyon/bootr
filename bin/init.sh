#!/bin/sh

# Mount proc
mount -t proc proc /proc -o rw,noexec,nosuid,nodev
# Mount sys
mount -t sysfs sys /sys -o rw,noexec,nosuid,nodev

# Mount root rw
mount / -o remount,rw

# Prep modules
depmod -A

# Populate /dev
/etc/init.d/udev start

# Mount filesystems
if [ `which lvm.static` ]; then
	lvm.static vgscan --ignorelockingfailure
	lvm.static vgchange -ay --ignorelockingfailure
fi
mount -a

# Setup a proper /tmp using tmpfs
cat /proc/mounts | grep -q "\s/tmp\s"
[ "x$?" != "x0" ] && mount -t tmpfs tmpfs /tmp

cat /proc/mounts | grep -q "\s/dev/pts\s"
[ "x$?" != "x0" ] && mount -t devpts devpts /dev/pts

# Set the hostname
hostname -F /etc/hostname

export machineType=`uname -m`

# Start novacomd service
if [ -e /sys/class/usb_gadget/config_num ]; then
        echo 2 > /sys/class/usb_gadget/config_num
else
        if [[ "$machineType" == "armv7l" ]];then
                modprobe g_composite product=0x8002
        elif [[ "$machineType" == "armv6l" ]];then
                modprobe g_composite product=0x8012
        else
                modprobe -q g_composite
        fi
	mkdir -p /dev/gadget
	mount -t gadgetfs gadget /dev/gadget
fi

novacomd &
powerd-lite &

