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
  # endpoint, username, and api_token are read from environment variables:
  #   PROXMOX_VE_ENDPOINT
  #   PROXMOX_VE_USERNAME
  #   PROXMOX_VE_API_TOKEN
}
