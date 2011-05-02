#!/bin/sh

sleep 1
hpid=`ps -C hexdump -o pid=`
sleep 10

for t in 3 2 1; do
    if [ "`ps -C hexdump -o pid=`" != "$hpid" ]; then
        exit
    fi
    bzcat /boot/bootr/data/$t.fbz > /dev/fb0
    sleep 1
done

if [ "`ps -C hexdump -o pid=`" = "$hpid" ]; then
    kill $hpid
    touch /media/ram/autobootr
fi

