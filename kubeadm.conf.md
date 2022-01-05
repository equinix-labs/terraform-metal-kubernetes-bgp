Kuberenetes Kubeadm Config Example
==================================

```yaml
apiVersion: kubeadm.k8s.io/v1beta1
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 10.99.254.3
  bindPort: 6443
nodeRegistration:
  name: sv-controller
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
kubernetesVersion: v1.13.3
apiServer:
  extraArgs:
    secure-port: "6443"
    bind-address: 10.99.254.3
controllerManager:
  extraArgs:
    bind-address: 10.99.254.3
scheduler:
  extraArgs:
    bind-address: 10.99.254.3
etcd:
  local:
    extraArgs:
      listen-client-urls: "https://127.0.0.1:2379,https://10.99.254.3:2379"
      advertise-client-urls: "https://10.99.254.3:2379"
      listen-peer-urls: "https://10.99.254.3:2380"
      initial-advertise-peer-urls: "https://10.99.254.3:2380"
      initial-cluster: "sv-controller=https://10.99.254.3:2380"
      initial-cluster-state: new
    serverCertSANs:
      - sv-controller
    peerCertSANs:
      - sv-controller
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
bindAddress: 10.99.254.3
```
