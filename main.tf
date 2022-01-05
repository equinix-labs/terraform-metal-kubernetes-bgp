provider "metal" {
  auth_token = var.auth_token
}

resource "metal_project" "kubenet" {
  organization_id = var.organization_id

  name = var.project_name

  bgp_config {
    deployment_type = "local"
    asn             = 65000
  }
}

resource "metal_ssh_key" "k8s-cluster-key" {
  name       = "k8s-bgp-cluster-access-key"
  public_key = tls_private_key.k8s_cluster_access_key.public_key_openssh
}

// General template used to install docker on Ubuntu 16.04
data "template_file" "install_docker" {
  template = file("${path.module}/templates/install-docker.sh.tpl")

  vars = {
    docker_version = var.docker_version
  }
}

data "template_file" "install_kubernetes" {
  template = file("${path.module}/templates/setup-kube.sh.tpl")

  vars = {
    kubernetes_version     = var.kubernetes_version
    kubernetes_apt_release = var.kubernetes_apt_release
  }
}
