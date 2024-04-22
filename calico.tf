resource "null_resource" "setup_calico" {
  connection {
    type        = "ssh"
    user        = "root"
    host        = equinix_metal_device.k8s_controller.access_public_ipv4
    private_key = tls_private_key.k8s_cluster_access_key.private_key_pem
  }

  provisioner "file" {
    source      = "${path.module}/network/calico"
    destination = "/tmp/"
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl apply -f /tmp/calico/",
    ]
  }

  depends_on = [equinix_metal_device.k8s_controller]
}
