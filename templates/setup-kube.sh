#!/bin/bash

HOSTNAME=$(hostname -s)
LOCAL_IP=$(ip a | grep "inet 10" | cut -d" " -f6 | cut -d"/" -f1)

echo "[----- Setting up kube settings -----]"

apt-get update
apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
# Only tested for kubernetes-xenial
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-$(lsb_release -cs) main
EOF
apt-get update
# TODO: Version the kuberenetes packages. Should use ${kubernetes_version}
apt-get install -y kubelet kubeadm kubectl cri-tools

# Make the kubelet use only the private IP to run it's management controller pods
echo "KUBELET_EXTRA_ARGS=\"--node-ip=$LOCAL_IP --address=$LOCAL_IP\"" > /etc/default/kubelet

echo "[---- Done setting up kube settings -----]"
