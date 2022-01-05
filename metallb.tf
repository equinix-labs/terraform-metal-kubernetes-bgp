# Get some public IPs to use for our load balancer
resource "metal_reserved_ip_block" "load_balancer_ips" {
  project_id = metal_project.kubenet.id
  facility   = var.facilities[0]
  quantity   = 2
}

# Enable BGP on each worker node
resource "metal_bgp_session" "kube_bgp" {
  count          = var.worker_count
  device_id      = metal_device.k8s_workers.*.id[count.index]
  address_family = "ipv4"
}

# Add Calico configs to make MetalLB work
resource "null_resource" "setup_calico_metallb" {
  connection {
    type        = "ssh"
    user        = "root"
    host        = metal_device.k8s_controller.access_public_ipv4
    private_key = tls_private_key.k8s_cluster_access_key.private_key_pem
  }

  provisioner "file" {
    content     = data.template_file.calico_metallb.rendered
    destination = "/tmp/calico/metallb.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "DATASTORE_TYPE=kubernetes KUBECONFIG=~/.kube/config calicoctl create -f /tmp/calico/metallb.yaml",
    ]
  }

  depends_on = [null_resource.setup_worker]
}

# Deploy MetalLB
resource "null_resource" "setup_metallb" {
  connection {
    type        = "ssh"
    user        = "root"
    host        = metal_device.k8s_controller.access_public_ipv4
    private_key = tls_private_key.k8s_cluster_access_key.private_key_pem
  }

  provisioner "file" {
    content     = data.template_file.metallb_config.rendered
    destination = "/tmp/metallb-config.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.9.3/manifests/namespace.yaml",
      "kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.9.3/manifests/metallb.yaml",
      "kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey=\"$(openssl rand -base64 128)\"",
      "kubectl apply -f /tmp/metallb-config.yaml",
    ]
  }

  depends_on = [null_resource.setup_calico_metallb]
}

# Add each node's peer to as a Calico bgppeer
resource "null_resource" "calico_node_peers" {
  count = var.worker_count

  connection {
    type        = "ssh"
    user        = "root"
    host        = metal_device.k8s_controller.access_public_ipv4
    private_key = tls_private_key.k8s_cluster_access_key.private_key_pem
  }

  provisioner "file" {
    source      = "${path.module}/scripts/calico-bgppeer.sh"
    destination = "/tmp/calico/bgppeer-${count.index}.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/calico/bgppeer-${count.index}.sh",
      "/tmp/calico/bgppeer-${count.index}.sh ${var.auth_token} ${element(metal_device.k8s_workers.*.id, count.index)} ${element(metal_device.k8s_workers.*.hostname, count.index)}",
    ]
  }

  depends_on = [null_resource.setup_calico_metallb]
}

data "template_file" "calico_metallb" {
  template = file("${path.module}/templates/calico-metallb.yaml.tpl")

  vars = {
    cidr = metal_reserved_ip_block.load_balancer_ips.cidr_notation
  }
}

data "template_file" "metallb_config" {
  template = file("${path.module}/templates/metallb-config.yaml.tpl")

  vars = {
    cidr = metal_reserved_ip_block.load_balancer_ips.cidr_notation
  }
}
