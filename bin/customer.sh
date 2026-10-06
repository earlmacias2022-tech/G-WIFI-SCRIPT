#!/bin/sh
check_mount() {
	mount -t jffs2 /dev/mtdblock3 /netis
	line=$(cat /proc/mounts |grep mtdblock3)
	if [ -n "$line" ]; then
		echo "mount sucess" > /dev/console
		return
	fi
	#0xA0000 size
	flash_erase -j /dev/mtd3 0 0
	mount -t jffs2 /dev/mtdblock3 /netis
	mkdir /netis/chilli
}

check_chilli() {
	[ -e /etc/config/hotspot ] || cp -f /etc/uci/hotspot /etc/config/
	[ -d /etc/config/www ] || (mkdir /etc/config/www; cp -f /web/back/* /etc/config/www/)
	[ -e /etc/config/chilli/defaults.tmp -a ! -e /etc/config/upgraded ] && return
	mkdir /etc/config/chilli
	rm -rf /etc/config/chilli/*
	rm -f /etc/config/upgraded
	cp -rf /etc/chilli_org/* /etc/config/chilli/
	sleep 5 && /bin/script/hotspot.sh &
}

check_mount
check_chilli

hst_dev=`flash get hst_dev_type | awk -F= '{print $2}'`
if [ "$hst_dev" == "0" ]; then
	flash set hst_disabled 1
fi
/bin/led_event.sh&

