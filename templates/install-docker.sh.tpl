#!/bin/bash
# vim: syntax=sh

echo "[----- Begin install-docker.sh ----]"

echo "Installing Docker ${docker_version}"

apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable"
apt-get update && apt-get install -y docker-ce=$(apt-cache madison docker-ce | grep ${docker_version} | head -1 | awk '{print $3}')

echo "[----- install-docker.sh Complete ------]"
