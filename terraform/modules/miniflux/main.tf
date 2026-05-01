terraform {
  required_version = ">= 1.14.7"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.98.1"
    }
  }
}

resource "proxmox_virtual_environment_container" "miniflux" {
  vm_id        = 400
  node_name    = "lab"
  description  = "Miniflux RSS"
  tags         = ["terraform", "lxc"]
  unprivileged = true

  features {
    nesting = true
  }

  cpu {
    cores = 1
  }

  memory {
    dedicated = 512
  }

  disk {
    datastore_id = "local-lvm"
    size         = 16
  }

  network_interface {
    name   = "eth0"
    bridge = "vmbr1"
  }

  operating_system {
    template_file_id = "local:vztmpl/debian-12-standard_12.12-1_amd64.tar.zst"
    type             = "debian"
  }

  initialization {

    user_account {
      keys = [trimspace(file("~/.ssh/id_ed25519.pub"))]
    }

    ip_config {
      ipv4 {
        address = "10.0.0.50/24"
        gateway = "10.0.0.1"
      }
    }

    hostname = "lyra"

  }

}

