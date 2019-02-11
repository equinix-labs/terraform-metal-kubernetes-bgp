Kuberenetes Kubeadm Config Example
==================================

```yaml
apiVersion: kubeadm.k8s.io/v1beta1
kind: InitConfiguration
bootstrapTokens:
  - token: tcqfab.8d5qen6tf2gaztam
    description: "kubeadm bootstrap token"
    ttl: "24h"
    usages:
    - signing
    - authentication
    groups:
    - system:bootstrappers:kubeadm:default-node-token
localAPIEndpoint:
  advertiseAddress: 10.99.14.9
  bindPort: 6443
nodeRegistration:
  criSocket: /var/run/dockershim.sock
  name: ewr1-controller-0
  taints:
  - key: "kubeadmNode"
    value: "master"
    effect: "NoSchedule"
  kubeletExtraArgs:
    cgroup-driver: "cgroupfs"
---
apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
clusterName: kubernetes
kubernetesVersion: v1.13.0
apiServer:
  extraArgs:
    secure-port: "6443"
    bind-address: 10.99.14.9
controllerManager:
  extraArgs:
    bind-address: 10.99.14.9
scheduler:
  extraArgs:
    bind-address: 10.99.14.9
etcd:
  local:
    extraArgs:
      listen-client-urls: "https://127.0.0.1:2379,https://10.99.14.9:2379"
      advertise-client-urls: "https://10.99.14.9:2379"
      listen-peer-urls: "https://10.99.14.9:2380"
      initial-advertise-peer-urls: "https://10.99.14.9:2380"
      initial-cluster: "ewr1-controller-0=https://10.99.14.9:2380"
      initial-cluster-state: new
    serverCertSANs:
      - ewr1-controller-0
    peerCertSANs:
      - ewr1-controller-0
networking:
  dnsDomain: cluster.local
  podSubnet: 172.16.0.0/12
  serviceSubnet: 192.168.0.0/16
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
clusterDNS:
- 192.168.0.10
clusterDomain: cluster.local
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
bindAddress: 10.99.14.9
```