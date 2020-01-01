resource "packet_device" "k8s_workers" {
  project_id       = packet_project.kubenet.id
  facilities       = var.facilities
  count            = var.worker_count
  plan             = var.worker_plan
  operating_system = "ubuntu_18_04"
  hostname         = format("%s-%s-%d", "${var.facilities[0]}", "worker", count.index)
  billing_cycle    = "hourly"
  tags             = ["kubernetes", "k8s", "worker"]
}

# Using a null_resource so the packet_device doesn't not have to wait to be initially provisioned
resource "null_resource" "setup_worker" {
  count = var.worker_count

  connection {
    user = "root"
    host = element(packet_device.k8s_workers.*.access_public_ipv4, count.index)
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
    source      = "${path.module}/scripts/install-calicoctl.sh"
    destination = "/tmp/install-calicoctl.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/*.sh",
      "/tmp/setup-base.sh",
      "/tmp/install-docker.sh",
      "/tmp/setup-kube.sh",
      data.external.kubeadm_join.result.command,
      "/tmp/install-calicoctl.sh",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl get nodes -o wide",
    ]

    on_failure = continue

    connection {
      type = "ssh"
      user = "root"
      host = packet_device.k8s_controller.access_public_ipv4
    }
  }
}

# We need to get the private IPv4 Gateway of each worker
data "external" "private_ipv4_gateway" {
  count   = var.worker_count
  program = ["${path.module}/scripts/gateway.sh"]

  query = {
    host = "${element(packet_device.k8s_workers.*.access_public_ipv4, count.index)}"
  }
}
