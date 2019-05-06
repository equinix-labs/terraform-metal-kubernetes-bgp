provider "packet" {
  auth_token = "${var.auth_token}"
}

resource "packet_project" "kubenet" {
  name = "kubenet"

  bgp_config {
    deployment_type = "local"
    asn             = 65000
  }
}

variable "facilities" {
  default = ["ewr1"]
}

variable "worker_count" {
  default = 2
}

variable "controller_plan" {
  description = "Set the Packet server type for the controller"
  default     = "t1.small.x86"
}

variable "worker_plan" {
  description = "Set the Packet server type for the workers"
  default     = "t1.small.x86"
}

data "template_file" "install_docker" {
  template = "${file("${path.module}/templates/install-docker.sh.tpl")}"

  vars = {
    docker_version = "${var.docker_version}"
  }
}

data "template_file" "install_kubernetes" {
  template = "${file("${path.module}/templates/setup-kube.sh.tpl")}"

  vars = {
    kubernetes_version = "${var.kubernetes_version}"
  }
}
