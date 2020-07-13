#!/bin/bash

set -x

API_KEY=$1
INSTANCE_UUID=$2
HOSTNAME=$3
PEER_IPS_AMOUNT=($(curl -X GET -H "X-Auth-Token: ${API_KEY}" "https://api.packet.net/devices/${INSTANCE_UUID}/bgp/neighbors" | jq ".bgp_neighbors[].peer_ips | length"))

i="0"

while [ $i -lt $PEER_IPS_AMOUNT ]
do

cat << EOF | DATASTORE_TYPE=kubernetes KUBECONFIG=~/.kube/config calicoctl create -f -
apiVersion: projectcalico.org/v3
kind: BGPPeer
metadata:
  name: $HOSTNAME-peer-$i
spec:
  peerIP: $(curl -X GET -H "X-Auth-Token: ${API_KEY}" "https://api.packet.net/devices/${INSTANCE_UUID}/bgp/neighbors" | jq -r ".bgp_neighbors[].peer_ips[$i]")
  node: $HOSTNAME-peer-$i
  asNumber: 65530
EOF

i=$[$i+1]

done
