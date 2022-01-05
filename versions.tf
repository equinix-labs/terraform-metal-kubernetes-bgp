terraform {
  required_providers {
    metal = {
      source  = "equinix/metal"
      version = ">= 3.2.1"
    }
  }
  required_version = ">= 0.14"
}
