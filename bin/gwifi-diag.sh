#!/bin/sh
# G-WIFI boot check. Started first thing from /etc/init.d/rcS, runs in the
# background and never blocks the boot.
#  - 45 s / 90 s / 180 s after boot it saves what is running into
#    /netis/boot-NN.txt (the settings partition: survives a reflash to stock)
#  - if SSH (dropbear) is not up by 90 s, it starts a rescue dropbear so the
#    router can still be reached over the cable (root / greywifi5254)
snap() {
  { echo "== $1 s after boot"; cat /proc/uptime; ps; ifconfig; echo "-- gwifi log"; tail -n 40 /tmp/gwifi.log; } > /tmp/boot-$1.txt 2>&1
  grep -q " /netis " /proc/mounts && cp /tmp/boot-$1.txt /netis/boot-$1.txt
}
sleep 45
snap 45
sleep 45
snap 90
# no address on the LAN (the boot stopped before the network came up)?
# give it the stock one so the rescue SSH below can be reached
if ! ifconfig br0 2>/dev/null | grep -q "inet addr"; then
  ifconfig br0 192.168.1.1 netmask 255.255.255.0 up 2>/dev/null || ifconfig eth0 192.168.1.1 netmask 255.255.255.0 up
  echo "RESCUE: the LAN had no address at 90 s -- set 192.168.1.1" >> /tmp/boot-90.txt
fi
if ! ps | grep -v grep | grep -q dropbear; then
  if [ ! -f /var/passwd ]; then
    echo "root::0:0:root:/:/bin/sh" > /var/passwd
    echo "root:x:0:root" > /var/group
  fi
  echo root:greywifi5254 | chpasswd -m
  dropbear
  echo "RESCUE: dropbear was not running at 90 s -- started a rescue one" >> /tmp/boot-90.txt
  grep -q " /netis " /proc/mounts && cp /tmp/boot-90.txt /netis/boot-90.txt
fi
sleep 90
snap 180
