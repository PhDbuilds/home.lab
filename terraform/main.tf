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
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.0"
    }
  }
}

provider "vault" {
  address = "http://10.0.0.101:8200"
}

data "vault_kv_secret_v2" "proxmox" {
  mount = "secret"
  name  = "terraform"
}

provider "proxmox" {
  endpoint  = data.vault_kv_secret_v2.proxmox.data["proxmox_ve_endpoint"]
  username  = data.vault_kv_secret_v2.proxmox.data["proxmox_ve_username"]
  api_token = data.vault_kv_secret_v2.proxmox.data["proxmox_ve_api_token"]
  insecure  = tobool(data.vault_kv_secret_v2.proxmox.data["proxmox_ve_insecure"])
}
