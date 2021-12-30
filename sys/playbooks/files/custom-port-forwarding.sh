#!/bin/bash


# Forward traffic to the old LXC container
if [ "$1" == "start" ]; then
    iptables -t nat -I PREROUTING -i eth0 -d 116.202.189.251 -j DNAT --to-destination 10.0.3.21 &&
    echo "Port forwarding to LXC container enabled successfully"

elif [ "$1" == "stop" ]; then
    iptables -t nat -D PREROUTING -i eth0 -d 116.202.189.251 -j DNAT --to-destination 10.0.3.21 &&
    echo "Port forwarding to LXC container stopped successfully"

elif [ "$1" == "status" ]; then
    echo "Listing matching rules:"
    iptables -t nat -L PREROUTING -v -n | grep '116.202.189.251'

else
    echo "ERROR: Use 'start', 'stop' or 'status' argument"

fi
