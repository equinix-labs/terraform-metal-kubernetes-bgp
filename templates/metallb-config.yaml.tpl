apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    peers:
    - peer-address: 127.0.0.1
      peer-asn: 65000
      my-asn: 65480
    address-pools:
    - name: packet-public
      protocol: bgp
      addresses:
      - ${cidr}
