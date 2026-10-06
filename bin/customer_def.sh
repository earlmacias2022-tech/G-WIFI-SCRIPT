#!/bin/sh
args=$1
echo args is $args > /dev/console
[ "$1" == "1" -o "$1" == 0 ] || return
hst_dev=`flash get hst_dev_type | awk -F= '{print $2}'`
rm -rf /etc/chilli/*
cp -f /etc/uci/* /etc/config/
rm -rf /etc/config/www/
mkdir /etc/config/www/
cp -f /web/back/* /etc/config/www/
if [ "$hst_dev" == "0" ]; then
	flash set hst_disabled 1
fi

