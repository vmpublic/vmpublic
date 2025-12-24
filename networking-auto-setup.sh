#!/bin/sh
set -eux
# assuming primary interface is eth0
ip addr add 10.0.0.2/24 dev eth0
ip link set eth0 up
ip route add default via 10.0.0.1
printf 'Initial setup complete. Now pinging cloudflare.com...\n'
ping -c 4 cloudflare.com
