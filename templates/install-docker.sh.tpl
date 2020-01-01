#!/bin/bash
# vim: syntax=sh

echo "[----- Begin install-docker.sh ----]"

echo "Installing Docker ${docker_version}"

echo '* libraries/restart-without-asking boolean true' | sudo debconf-set-selections

# Based on from https://kubernetes.io/docs/setup/cri/#docker

# Install Docker CE
## Set up the repository:
### Install packages to allow apt to use a repository over HTTPS
apt-get update \
  && apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common

### Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

### Add Docker apt repository
add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
  $(lsb_release -cs) \
  stable"

## Install Docker CE
apt-get update \
  && apt-get install -y \
  docker-ce=$(apt-cache madison docker-ce | grep ${docker_version} | head -1 | awk '{print $3}')

# Setup daemon
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

# Restart docker
systemctl daemon-reload
systemctl restart docker

echo "[----- install-docker.sh Complete ------]"
