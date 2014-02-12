#!/bin/sh

check_hw(){
    hw="`cat /proc/cpuinfo | grep Hardware | sed 's/.*: //'`"
    case $hw in
        "Sirloin OMAP3430 board")
            hw=pre
            ;;
        "Sirloin OMAP3630 board")
            hw=pre2
            ;;
        "Rib")
            hw=pre3
            ;;
        "Shank")
            hw=veer
            ;;
        "TENDERLOIN")
            hw=touchpad
            ;;
        "SHORTLOIN")
            hw=touchpadgo
            ;;
        *)
            echo "Unsupported Device. Exiting..."
            exit
        ;;
    esac
}

check_error(){
    if [ $? -ne 0 ]; then
        echo "  [ERROR] ${1} failed. Exiting..."; exit
    else
        echo "  [OK] ${1}"
    fi
}

create_backup(){
    echo " Backing up /boot/sbin/init..."
    if [ -x /boot/sbin/init.backup.bootr ]; then
        echo "  [OK] backup init.backup.bootr already exists."
    else
        mv /boot/sbin/init /boot/sbin/init.backup.bootr
        check_error "saved init.backup.bootr"
    fi
}

restore_backup(){
    echo " Restoring original /boot/sbin/init..."
    if [ -x /boot/sbin/init.backup.bootr ]; then
        rm /boot/sbin/init
        mv /boot/sbin/init.backup.bootr /boot/sbin/init
        check_error "from init.backup.bootr"
    elif [ -e /boot/sbin/init.bootr ]; then
        echo "  [WARNING] Backup not exists and Bootr installed, try restore from /sbin/boot-init"
        rm /boot/sbin/init
        cp /sbin/boot-init /boot/sbin/init
        check_error "from /sbin/boot-init"
    fi
}

create_bootr_inits(){
    if [ "`cat /etc/palm-build-info | grep 'OS 1.'`" != "" ]; then veros=1x
    elif [ "`cat /etc/palm-build-info | grep 'OS 2.'`" != "" ]; then veros=2x
    else veros=3x; fi
    echo " Create Bootr bootscripts from patches on $veros..."
    patchcmd=/usr/bin/patch
    if [ ! -x $patchcmd ]; then patchcmd=/media/cryptofs/apps/usr/bin/patch; fi
    if [ ! -x $patchcmd ]; then echo "   [ERROR] Command 'patch' not found, install package 'GNU Patch' using Preware or WOSQI and try again. Exiting..."; exit; fi
    cd /boot/bootr/data/patch
    for patch in `ls init.*.$veros.patch` ; do
        init=`echo $patch|sed -r "s/.($veros).patch//g"`
        cp /boot/sbin/init.backup.bootr /boot/sbin/$init
        $patchcmd -p0 <$patch
        check_error "$init"
    done
    cp /etc/miniboot.sh /boot/bootr/bin/init.sh
    $patchcmd -p0 <bootr-init.sh.$veros.patch
    check_error "init.sh"
}

remove_bootr_inits(){
    echo " Removing Bootr bootscripts from /boot/sbin ..."
    cd /boot/bootr/data/patch
    if [ "`cat /etc/palm-build-info | grep 'OS 1.'`" != "" ]; then veros=1x
    elif [ "`cat /etc/palm-build-info | grep 'OS 2.'`" != "" ]; then veros=2x
    else veros=3x; fi
    for init in `ls init.*.$veros.patch|sed -r "s/.($veros).patch//g"` ; do
        rm /boot/sbin/$init
        check_error "$init"
    done
}

check_hw

case $1 in
    install)
        echo "Installing Bootr..."
        mount -o remount,rw /boot
        create_backup
        create_bootr_inits
        cd /boot/sbin
        echo " Linking Bootr init..."
        ln -sf init.bootr init
        check_error "Linked init -> init.bootr"
        echo "Wait for sync disk writes..."
        sync
        mount -o remount,ro /boot
        echo "Done. You can now reboot into Bootr."
        ;;
    uninstall)
        if [ ! -x /boot/sbin/init.bootr ]; then echo 'Bootr is not installed.'; exit; fi
        . /boot/bootr/os/$hw/webos
        echo "Uninstalling Bootr..."
        mount -o remount,rw /boot
        restore_backup
        remove_bootr_inits
        cd /boot
        ln -sf $kernel uImage
        echo " Linking webOS kernel..."
        check_error "Linked uImage -> $kernel"
        echo "Waiting for sync disk writes..."
        sync
        mount -o remount,ro /boot
        echo "Done. You can now reboot into webOS without Bootr."
        ;;
    *)
        echo ''
        echo '  *** This Script will install or uninstall Bootr on your Palm Pre (2) or HP Veer/Pre 3/Touchpad (Go) ***'
        echo ''
        echo '  * Requirements'
        echo '     WebOS - installed on /dev/mapper/store-root'
        echo '           - kernel is at /boot/uImage-2.6.24-palm-joplin-3430'
        echo '       SHR - installed on /dev/mapper/store-fso'
        echo '           - kernel is at /boot/uImage-palmpre.bin'
        echo '   Android - boot/system/data ext3 images in /media/internal/android'
        echo '           - kernel is at /boot/uImage.usbnet'
        echo ''
        echo '  If you really want to install Bootr to /boot/sbin now,'
        echo '  run this script with the "install" argument:'
        echo '  sh install.sh install'
        echo ''
        echo '  If you really want to uninstall Bootr from /boot/sbin now,'
        echo '  run this script with the "uninstall" argument:'
        echo '  sh install.sh uninstall'
        echo ''
        ;;
esac
