resource "equinix_metal_device" "k8s_workers" {
  project_id       = equinix_metal_project.kubenet.id
  metro            = var.metro
  count            = var.worker_count
  plan             = var.worker_plan
  operating_system = var.metal_os
  hostname         = format("%s-%s-%d", var.metro, "worker", count.index)
  billing_cycle    = "hourly"
  tags             = ["kubernetes", "k8s", "worker"]
}

# Using a null_resource so the equinix_metal_device doesn't not have to wait to be initially provisioned
resource "null_resource" "setup_worker" {
  count = var.worker_count

  connection {
    type        = "ssh"
    user        = "root"
    host        = element(equinix_metal_device.k8s_workers.*.access_public_ipv4, count.index)
    private_key = tls_private_key.k8s_cluster_access_key.private_key_pem
  }

  provisioner "file" {
    source      = "${path.module}/scripts/setup-base.sh"
    destination = "/tmp/setup-base.sh"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/install-docker.sh.tpl", {
      docker_version = var.docker_version
    })
    destination = "/tmp/install-docker.sh"
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/setup-kube.sh.tpl", {
      kubernetes_version     = var.kubernetes_version
      kubernetes_apt_release = var.kubernetes_apt_release
    })
    destination = "/tmp/setup-kube.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/install-calicoctl.sh"
    destination = "/tmp/install-calicoctl.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/bgp-routes.sh"
    destination = "/tmp/bgp-routes.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/*.sh",
      "/tmp/setup-base.sh",
      "/tmp/install-docker.sh",
      "/tmp/setup-kube.sh",
      "${data.external.kubeadm_join.result.command}",
      "/tmp/install-calicoctl.sh",

      # Only enable the execution of this next line if you see issues with BGP peering
      # Some BGP speakers will not respect source routing so adding static routes can help.
      #      "/tmp/bgp-routes.sh",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl get nodes -o wide",
    ]

    on_failure = continue

    connection {
      type        = "ssh"
      user        = "root"
      host        = equinix_metal_device.k8s_controller.access_public_ipv4
      private_key = tls_private_key.k8s_cluster_access_key.private_key_pem
    }
  }
}

# We need to get the private IPv4 Gateway of each worker
data "external" "private_ipv4_gateway" {
  count   = var.worker_count
  program = ["${path.module}/scripts/gateway.sh"]

  query = {
    host = element(equinix_metal_device.k8s_workers.*.access_public_ipv4, count.index)
  }
}
