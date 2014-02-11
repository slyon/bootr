#!/bin/sh

if [ -d /media/cryptofs/apps/ ]; then ifnotdebug='echo skip:'; fi

$ifnotdebug sh /boot/bootr/bin/init.sh

rm /media/ram/autobootr ### need for timeout on touchpad

check_hw(){
    evdev=event1
    btnboot=006b00010 #Power button
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
            export ED=1
            evdev=event0
            ;;
        "Shank")
            hw=veer
            export ED=1
            evdev=event0
            ;;
        "TENDERLOIN")
            hw=touchpad
            export HD=1
            evdev=event0
            btnboot=00e800010 #Center button
            ;;
        "SHORTLOIN")
            hw=touchpadgo
            export HD=1
            evdev=event0
            btnboot=00e800010 #Center button
            ;;
        *)
            echo "Unsupported Device. Exiting..."
            exit
            ;;
    esac
}

show_fbz(){
    if [ "$HD" = "1" ]; then
        bzcat /boot/bootr/data/${1}HD.fbz > /dev/fb0
    elif [ "$ED" = "1" ]; then
        bzcat /boot/bootr/data/${1}ED.fbz > /dev/fb0
    else
        bzcat /boot/bootr/data/$1.fbz > /dev/fb0
    fi
    echo 0,0 >/sys/class/graphics/fb0/pan ### need for pre3
}

select_os(){
    if [ "`echo $event | grep $1`" != "" ]; then
        while true; do
            for os in $2; do
                if [ "$switch" = "1" ]; then OS=$os;switched=1;unset switch; break; fi
                if [ "$os" = "$OS" ]; then switch=1; fi
            done
            if [ "$switched" = "1" ]; then unset switched; break; fi
        done
        pong_fb "2 4 8 10 15 20 15 10 5 0 5 10 15 17 17 15 12 10 8 6 4 2 0" 50
        show_fbz $OS
        do_led $3 150
    fi
}

change_and_reboot(){
    . /boot/bootr/os/$hw/$OS
    show_fbz $OS
    do_led center 500
    pong_fb "20 30 60 80 100 120 120 80 100 120 80 90 100 110 120 90 95 100 105 110 115 120 105 110 115 120 110 113 115 118 120" 750
    mount -o remount,rw /boot
    cd /boot/sbin
    ln -sf init.$OS.bootr init
    cd /boot
    ln -sf $kernel uImage
    $ifnotdebug tellbootie
}

check_os_and_kernel(){
    for os in `ls /boot/bootr/os/$hw/`; do
        . /boot/bootr/os/$hw/$os
       if [ -f /boot/$kernel ]; then
        os_installed="$os_installed $os"
        os_installed_rev="$os $os_installed_rev"
       fi
    done
}

do_led(){
    bri="0 20 40 60 80 90 95 100 100 95 90 80 70 60 50 40 30 20 10 0"
    for i in $bri; do
        echo $i >/sys/class/leds/core_navi_$1/brightness
        w=$2
        while [ $w -gt 0 ]; do
            w=$(($w-1))
        done
    done
}

pong_fb(){
    for i in $1 ; do
        if [ "$HD" = "1" ]; then i=$((($i*2)-50)); fi
        if [ "$ED" = "1" ]; then i=$(($i*2)); fi
        echo 0,$i >/sys/class/graphics/fb0/pan
        w=$2
        while [ $w -gt 0 ]; do
            w=$(($w-1))
        done
    done
}

set_lcd(){
    echo $1 > /sys/class/display/lcd.0/brightness
}

OS=webos
check_hw
set_lcd 50
check_os_and_kernel

show_fbz $OS

sh /boot/bootr/bin/timeout.sh &

while true;
    do
    event=`hexdump -e '1/1 "%.2x"' /dev/input/$evdev -n 16`
    # Boot Button Released or MuteSwitch moved to ON(on Phones)
    # in check_hw is set $btnboot as Power(on Phones)/Center(on Touchpad)
    if [ "`echo $event | grep $btnboot`" != "" -o "`echo $event | grep 5000500010`" != "" -o -e /media/ram/autobootr ]; then
        change_and_reboot
        break
    fi
    #VolumeUp Button Released
    select_os 007300010 "$os_installed_rev" left
    #VolumeDown Button Released
    select_os 007200010 "$os_installed" right
    #Center Button Released (only on Phones)
    select_os 00e800010 "$os_installed" right
done

exit 0
