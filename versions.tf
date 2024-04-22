terraform {
  provider_meta "equinix" {
    module_name = "metal-kubernetes-bgp"
  }

  required_providers {
    equinix = {
      source  = "equinix/equinix"
      version = ">= 1.30"
    }
  }
  required_version = ">= 1.0"
}
