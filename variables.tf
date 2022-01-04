variable "auth_token" {
  description = "Your Equinix Metal API key"
}

variable "organization_id" {
  description = "Your Equinix Metal organization where the project k8s-bgp will be created"
}

variable "project_name" {
  description = "The project name, k8s-bgp is used as default if not specified"
  default     = "k8s-bgp"
}

variable "docker_version" {
  default = "19.03.10"
}

variable "kubernetes_version" {
  description = "Kubernetes Version"
  default     = "1.18.3"
}

variable "kubernetes_port" {
  description = "Kubernetes API Port"
  default     = "6443"
}

variable "kubernetes_dns_ip" {
  description = "Kubernetes DNS IP"
  default     = "192.168.0.10"
}

variable "kubernetes_cluster_cidr" {
  description = "Kubernetes Cluster Subnet"
  default     = "172.16.0.0/12"
}

variable "kubernetes_service_cidr" {
  description = "Kubernetes Service Subnet"
  default     = "192.168.0.0/16"
}

variable "kubernetes_dns_domain" {
  description = "Kubernetes Internal DNS Domain"
  default     = "cluster.local"
}

variable "metro" {
  default = "sv"
}

variable "worker_count" {
  default = 2
}

variable "controller_plan" {
  description = "Set the Equinix Metal server type for the controller"
  default     = "c3.small.x86"
}

variable "worker_plan" {
  description = "Set the Equinix Metal server type for the workers"
  default     = "c3.small.x86"
}

variable "metal_os" {
  description = "Set the Equinix Metal OS for the controller and workers"
  default     = "ubuntu_20_04"
}
