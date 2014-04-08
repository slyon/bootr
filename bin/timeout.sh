#!/bin/sh

sleep 1
hpid=`ps -C hexdump -o pid=`
sleep 10

for t in 3 2 1; do
    if [ "`ps -C hexdump -o pid=`" != "$hpid" ]; then
        exit
    fi
    if [ "$HD" = "1" ]; then
        bzcat /boot/bootr/data/${t}HD.fbz > /dev/fb0
    elif [ "$ED" = "1" ]; then
        bzcat /boot/bootr/data/${t}ED.fbz > /dev/fb0
    elif [ "$SDV" = "1" ]; then
        bzcat /boot/bootr/data/${t}SDV.fbz > /dev/fb0
    else
        bzcat /boot/bootr/data/$t.fbz > /dev/fb0
    fi
    echo 0,0 >/sys/class/graphics/fb0/pan ### need for pre3
    sleep 1
done

if [ "`ps -C hexdump -o pid=`" = "$hpid" ]; then
    kill $hpid
    touch /media/ram/autobootr
fi
