#!/bin/sh
# G-WIFI Lite launcher. Started from /etc/init.d/rcS (the Netis boot program
# /bin/script/cscripts never runs post_startup.sh, so that hook is dead).
# Waits until the Netis boot has finished -- dropbear is one of the last
# things it starts -- then gives it 20 s more, then runs gwifi. If gwifi
# crashes 5 times in a row within a minute of starting, it is left off and
# the router is put back on the address its own boot gave it, so it can
# still be reached.
# Create /netis/gwifi.disable to keep gwifi off entirely.
n=0
while [ $n -lt 180 ]; do
  ps | grep -v grep | grep -q dropbear && break
  sleep 1
  n=`expr $n + 1`
done
sleep 20
if [ -f /netis/gwifi.disable ]; then
  echo "gwifi disabled by /netis/gwifi.disable" > /tmp/gwifi.log
  exit 0
fi
echo "gwifi-start: boot finished after ~$n s, starting gwifi" > /tmp/gwifi.log
# the address the Netis's own boot gave the LAN, to put back if gwifi
# cannot run (from 1.0.9 the stock boot itself uses 10.0.0.1)
stockip=`ifconfig br0 2>/dev/null | awk '/inet addr:/{sub(/.*inet addr:/,"");print $1}'`
[ -n "$stockip" ] || stockip=192.168.1.1
n=0
while [ $n -lt 5 ]; do
  read a rest < /proc/uptime
  a=${a%.*}
  /bin/gwifi >>/tmp/gwifi.log 2>&1 </dev/null
  read b rest < /proc/uptime
  b=${b%.*}
  if [ `expr $b - $a` -lt 60 ]; then n=`expr $n + 1`; else n=0; fi
  echo "gwifi exited after `expr $b - $a` s (quick exits in a row: $n)" >> /tmp/gwifi.log
  sleep 5
done
echo "gwifi stopped: it crashed 5 times in a row -- putting the router back on $stockip" >> /tmp/gwifi.log
ifconfig br0 $stockip netmask 255.255.255.0
killall dnsmasq 2>/dev/null
sleep 1
dnsmasq -C /var/dnsmasq.conf
