#!/bin/bash

set -e

# Extract "host" argument from the input into HOST shell variable
eval "$(jq -r '@sh "HOST=\(.host)"')"

# Get the gateway ip
PEER_IP=$(ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    root@$HOST route -n | grep '10.0.0.0' | awk '{$1=$1};1' | cut -d' ' -f2)

# Produce a JSON object containing the join command
jq -n --arg peer_ip "$PEER_IP" '{"peer_ip":$peer_ip}'
