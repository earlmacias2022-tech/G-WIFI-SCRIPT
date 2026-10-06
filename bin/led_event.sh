#!/bin/sh
old_led=1
while true; do
	nsdaemon=`ps |grep  NetisDaemon |grep -v grep`
	led=`cat /proc/load_default`
	internet=`cat /tmp/internet_online_check`
	wifi=`ifconfig wlan0 |grep UP`
	if [ -z "$nsdaemon" -a  ! -e /var/run/fwd_pid ]; then
		exit 0
	fi

	if [ "$led" != "0" ];then
		echo P > /proc/gpio
		echo D > /proc/gpio
		echo 1 > /proc/gpio
		echo A > /proc/gpio
		usleep 500000
		old_led=$led
		continue
	fi

	if [ "$led" != "$old_led" ];then
		echo o > /proc/gpio
	fi
	old_led=$led
	if [ -e /var/run/fwd_pid ]; then
		echo p > /proc/gpio
		usleep 500000
		echo P > /proc/gpio
		continue
	fi
	if [ "$internet" == "1" ];then
		echo D > /proc/gpio
	else
		echo d > /proc/gpio
	fi
	if [ -n "$wifi" ];then
		echo 1 > /proc/gpio
	else
		echo 0 > /proc/gpio
	fi
	sleep 1
done

