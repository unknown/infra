terraform {
  required_providers {
    nomad = {
      source  = "hashicorp/nomad"
      version = "~> 2.4.0"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.6.0"
    }
  }
}

variable "hcloud_token" {
  type = string
}

module "csi_driver" {
  source       = "./csi-driver"
  hcloud_token = var.hcloud_token
}

module "postgres" {
  depends_on = [module.csi_driver]
  source     = "./postgres"
}

module "redis" {
  depends_on = [module.csi_driver]
  source     = "./redis"
}
