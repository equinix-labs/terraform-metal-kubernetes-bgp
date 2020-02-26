resource "tls_private_key" "default" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "local_file" "private_key_pem" {

  depends_on = [tls_private_key.default]

  content    = tls_private_key.default.private_key_pem
  filename   = "cluster-private-key.pem"
}

resource "local_file" "public_key_pem" {

  depends_on = [tls_private_key.default]

  content    = tls_private_key.default.public_key_pem
  filename   = "cluster-public-key.pem"
}

resource "local_file" "public_key_openssh" {

  depends_on = [tls_private_key.default]

  content    = tls_private_key.default.public_key_openssh
  filename   = "cluster-openssh.pub"
}

resource "null_resource" "chmod" {
  depends_on = [local_file.private_key_pem]

  triggers = {
    local_file_private_key_pem = "local_file.private_key_pem"
  }

  provisioner "local-exec" {
    command = "chmod 600 default.pem"
  }
}
