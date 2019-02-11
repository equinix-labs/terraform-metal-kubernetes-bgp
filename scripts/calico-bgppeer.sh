#!/bin/bash

set -x

HOSTNAME=$1
PEER_IP=$2

cat << EOF | DATASTORE_TYPE=kubernetes KUBECONFIG=~/.kube/config calicoctl create -f -
apiVersion: projectcalico.org/v3
kind: BGPPeer
metadata:
  name: $HOSTNAME
spec:
  peerIP: $PEER_IP
  node: $HOSTNAME
  asNumber: 65530
EOF
