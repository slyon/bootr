#!/bin/sh
# read default OS and alternatives based of HW
hw="`cat /proc/cpuinfo | grep Hardware | sed 's/.*: //'`"
case $hw in
    "Sirloin OMAP3430 board")
        hw=pre
        ;;
    "Sirloin OMAP3630 board")
        hw=pre2
        ;;
    *)
        echo "Don't supported Pre model. Exiting..."
        exit
        ;;
esac
. /boot/bootr/bootr.os.$hw

OS=$1
kernel=`set | grep $OS= | sed -r "s/.*kernel=//" | sed 's/;.*//'`
os_supported=`set | grep "='kernel"|sed 's/=.*//'`

if [ "$OS" = "" ]; then
    echo "usage $0 [`echo $os_supported|sed -r 's/ /\|/g'`]"
elif [ ! -x /boot/sbin/init.bootr ]; then
    echo -e "Bootr is NOT installed\nInstall it using /boot/bootr/bin/install.sh before use..."
elif [ ! -f /boot/$kernel ]; then
    echo -e "Kernel $kernel for $OS not found...\nIs $OS really installed ?"
else
    mount -o remount,rw /boot

    echo "Preparing next boot to $OS..."
    cd /boot/sbin
    echo " change init to /boot/sbin/init.$OS.bootr"
    ln -sf init.$OS.bootr init
    cd /boot
    echo " change kernel to /boot/$kernel"
    ln -sf $kernel uImage
    echo "Wait for sync disk writes..."
    sync
    echo "Rebooting into $OS..."
    tellbootie
fi
