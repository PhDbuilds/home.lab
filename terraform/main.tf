# -------------------------------------------------------------------
# Proxmox Home Lab 
# -------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.78"
    }
  }
}

provider "proxmox" {
  ssh {
    agent    = true
    username = "root"
  }
}
