#!/bin/bash

set -x

GATEWAY_PRIVATE_IPV4=($(curl https://metadata.packet.net/metadata | jq -r ".network.addresses[] | select(.public == false) | .gateway"))


PEER_IPS_AMOUNT=($(curl https://metadata.packet.net/metadata | jq ".bgp_neighbors[].peer_ips | length"))

i="0"

while [ $i -lt $PEER_IPS_AMOUNT ]
do

PEER_IP=$(curl https://metadata.packet.net/metadata | jq -r ".bgp_neighbors[].peer_ips[$i]")

ip route add $PEER_IP via $GATEWAY_PRIVATE_IPV4 dev bond0


i=$[$i+1]

done
