variable "hostname" {
  default = "controller"
}

// Setup the kubernetes controller node
resource "metal_device" "k8s_controller" {
  project_id       = metal_project.kubenet.id
  metro            = var.metro
  plan             = var.controller_plan
  operating_system = var.metal_os
  hostname         = format("%s-%s", var.metro, "${var.hostname}")
  billing_cycle    = "hourly"
  tags             = ["kubernetes", "k8s", "controller"]

  connection {
    type        = "ssh"
    user        = "root"
    host        = metal_device.k8s_controller.access_public_ipv4
    private_key = tls_private_key.k8s_cluster_access_key.private_key_pem
  }

  provisioner "file" {
    source      = "${path.module}/scripts/setup-base.sh"
    destination = "/tmp/setup-base.sh"
  }

  provisioner "file" {
    content     = data.template_file.install_docker.rendered
    destination = "/tmp/install-docker.sh"
  }

  provisioner "file" {
    content     = data.template_file.install_kubernetes.rendered
    destination = "/tmp/setup-kube.sh"
  }

  provisioner "file" {
    content     = data.template_file.setup_kubeadm.rendered
    destination = "/tmp/setup-kubeadm.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/install-calicoctl.sh"
    destination = "/tmp/install-calicoctl.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/*.sh",
      "/tmp/setup-base.sh",
      "/tmp/install-docker.sh",
      "/tmp/setup-kube.sh",
      "/tmp/setup-kubeadm.sh",
      "/tmp/install-calicoctl.sh",
    ]
  }
}

data "external" "kubeadm_join" {
  program = ["${path.module}/scripts/kubeadm-token.sh"]

  query = {
    host = metal_device.k8s_controller.access_public_ipv4
  }

  # Make sure to only run this after the controller is up and setup
  depends_on = [metal_device.k8s_controller]
}

data "template_file" "setup_kubeadm" {
  template = file("${path.module}/templates/setup-kubeadm.sh.tpl")

  vars = {
    kubernetes_version      = var.kubernetes_version
    kubernetes_port         = var.kubernetes_port
    kubernetes_dns_ip       = var.kubernetes_dns_ip
    kubernetes_dns_domain   = var.kubernetes_dns_domain
    kubernetes_cluster_cidr = var.kubernetes_cluster_cidr
    kubernetes_service_cidr = var.kubernetes_service_cidr
  }
}
