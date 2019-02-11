resource "null_resource" "setup_calico" {
  connection {
    user = "root"
    host = "${packet_device.k8s_controller.access_public_ipv4}"
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

  depends_on = ["packet_device.k8s_controller"]
}
