variable "auth_token" {
  description = "Your Packet API key"
}

variable "organization_id" {
  description = "Your Packet organization where the project k8s-bgp will be created"
}

variable "project_name" {
  description = "The project name, k8s-bgp is used as default if not specified"
  default = "k8s-bgp"
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
}

variable "kubernetes_dns_ip" {
  description = "Kubernetes DNS IP"
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
