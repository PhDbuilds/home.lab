terraform {
  required_version = ">= 1.14.7"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.98.1"
    }
  }
}

provider "proxmox" {
  api_token = var.proxmox_api_token
  endpoint  = "https://192.168.1.180:8006"
  insecure  = true
}

module "polaris" {
  source = "./modules/OPNsense"
}

module "sirius" {
  source = "./modules/alma-full/"
}

module "alma-minimal" {
  source = "./modules/alma-minimal/"
}

module "vega" {
  source = "./modules/vega/"
}

module "miniflux" {
  source = "./modules/miniflux/"
}
