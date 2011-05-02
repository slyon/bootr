#!/bin/sh

sleep 1
hpid=`ps -C hexdump -o pid=`
sleep 10

for t in 3 2 1; do
    bzcat /boot/bootr/data/$t.fbz > /dev/fb0
    sleep 1
    if [ "`ps -C hexdump -o pid=`" != "$hpid" ]; then
        exit
    fi
done

if [ "`ps -C hexdump -o pid=`" = "$hpid" ]; then
    kill $hpid
    touch /media/ram/autobootr
fi

