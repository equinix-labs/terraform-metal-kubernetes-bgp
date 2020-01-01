resource "null_resource" "setup_istio" {
  connection {
    user = "root"
    host = packet_device.k8s_controller.access_public_ipv4
  }

  provisioner "file" {
    source      = "${path.module}/scripts/install-istio.sh"
    destination = "/tmp/install-istio.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/*.sh",
      "/tmp/install-istio.sh",
    ]
  }

  depends_on = [packet_device.k8s_controller]
}
