apiVersion: projectcalico.org/v3
kind: BGPConfiguration
metadata:
  name: default
spec:
  logSeverityScreen: Info
  nodeToNodeMeshEnabled: true
  asNumber: 65000

---

apiVersion: projectcalico.org/v3
kind: BGPPeer
metadata:
  name: metallb
spec:
  peerIP: 127.0.0.1
  asNumber: 65480

---

apiVersion: projectcalico.org/v3
kind: IPPool
metadata:
  name: metallb-packet-public
spec:
  cidr: ${cidr}
  disabled: true
