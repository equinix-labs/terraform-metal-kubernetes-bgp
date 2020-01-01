#!/bin/bash

echo '* libraries/restart-without-asking boolean true' | sudo debconf-set-selections

HOSTNAME=$(hostname -s)
# Get Packet server's private IP address
LOCAL_IP=$(ip a | grep "inet 10" | cut -d" " -f6 | cut -d"/" -f1)

get_version () {
	PACKAGE=$1
	VERSION=$2
	apt-cache madison $PACKAGE | grep $VERSION | head -1 | awk '{print $3}'
}

echo "[----- Setting up kubernetes configurations -----]"

apt-get update
apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
# deb http://apt.kubernetes.io/ kubernetes-$(lsb_release -cs) main
deb http://apt.kubernetes.io/ kubernetes-xenial main # bionic repo doesnt exist yet
EOF
apt-get update
apt-get install -y \
	kubelet=$(get_version kubelet ${kubernetes_version}) \
	kubeadm=$(get_version kubeadm ${kubernetes_version}) \
	kubectl=$(get_version kubectl ${kubernetes_version}) \
	cri-tools

# Make the kubelet use only the private IP to run it's management controller pods
echo "KUBELET_EXTRA_ARGS=\"--node-ip=$LOCAL_IP --address=$LOCAL_IP\"" > /etc/default/kubelet

# enable autocompletion for kubectl
echo "source <(kubectl completion bash)" >> ~/.bashrc
echo "[---- Done setting up kubernetes configurations -----]"
