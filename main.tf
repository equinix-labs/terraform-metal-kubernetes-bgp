provider "equinix" {
  auth_token = var.auth_token
}

resource "equinix_metal_project" "kubenet" {
  organization_id = var.organization_id

  name = var.project_name

  bgp_config {
    deployment_type = "local"
    asn             = 65000
  }
}

resource "equinix_metal_ssh_key" "k8s-cluster-key" {
  name       = "k8s-bgp-cluster-access-key"
  public_key = tls_private_key.k8s_cluster_access_key.public_key_openssh
}


