#!/bin/bash
# vim: syntax=sh

HOSTNAME=$(hostname -s)
LOCAL_IP=$(ip a | grep "inet 10" | cut -d" " -f6 | cut -d"/" -f1)

echo "[----- Setting up Kubernetes using kubeadm ----]"

cat <<EOF >kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta1
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: $LOCAL_IP
  bindPort: ${kubernetes_port}
nodeRegistration:
  name: $HOSTNAME
  taints:
  - key: "kubeadmNode"
    value: "master"
    effect: "NoSchedule"
  kubeletExtraArgs:
    cgroup-driver: "systemd"
---
apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
clusterName: kubernetes
kubernetesVersion: ${kubernetes_version}
apiServer:
  extraArgs:
    secure-port: "${kubernetes_port}"
    bind-address: $LOCAL_IP
controllerManager:
  extraArgs:
    bind-address: $LOCAL_IP
scheduler:
  extraArgs:
    bind-address: $LOCAL_IP
etcd:
  local:
    extraArgs:
      listen-client-urls: "https://127.0.0.1:2379,https://$LOCAL_IP:2379"
      advertise-client-urls: "https://$LOCAL_IP:2379"
      listen-peer-urls: "https://$LOCAL_IP:2380"
      initial-advertise-peer-urls: "https://$LOCAL_IP:2380"
      initial-cluster: "$HOSTNAME=https://$LOCAL_IP:2380"
      initial-cluster-state: new
    serverCertSANs:
      - $HOSTNAME
    peerCertSANs:
      - $HOSTNAME
networking:
  dnsDomain: ${kubernetes_dns_domain}
  podSubnet: ${kubernetes_cluster_cidr}
  serviceSubnet: ${kubernetes_service_cidr}
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
clusterDNS:
- ${kubernetes_dns_ip}
clusterDomain: ${kubernetes_dns_domain}
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
bindAddress: $LOCAL_IP
EOF

kubeadm init --config kubeadm-config.yaml

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "[---- Done setting up kubernetes -----]"
