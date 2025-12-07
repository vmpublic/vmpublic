#!/bin/sh
set -eux
# assuming primary interface is ens5
ip addr add 10.0.0.2/24 dev ens5
ip link set ens5 up
ip route add default via 10.0.0.1
printf 'Initial setup complete. Now pinging cloudflare.com...\n'
ping -c 4 cloudflare.com
