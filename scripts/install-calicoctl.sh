#!/bin/bash

CALICO_VERSION="v3.12.0"
# Download the matching version
curl -L  \
	https://github.com/projectcalico/calicoctl/releases/download/$CALICO_VERSION/calicoctl \
	-o /usr/local/bin/calicoctl

# Make it executable
chmod +x /usr/local/bin/calicoctl
