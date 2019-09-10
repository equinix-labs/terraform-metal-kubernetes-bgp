variable "auth_token" {
  description = "Your Packet API key"
}

variable "docker_version" {
  default = "18.06.2"
}

variable "kubernetes_version" {
  description = "Kubernetes Version"
  default     = "1.14.1"
}

variable "kubernetes_port" {
  description = "Kubernetes API Port"
  default = "6443"
}

variable "kubernetes_dns_ip" {
  description = "Kubernetes DNS IP"
  default = "192.168.0.10"
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
