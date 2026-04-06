terraform {
  required_version = ">= 1.14.7"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.98.1"
    }
  }
}

resource "proxmox_virtual_environment_vm" "polaris" {
  name          = "polaris"
  node_name     = "lab"
  on_boot       = true
  started       = true
  scsi_hardware = "virtio-scsi-single"
  machine       = "q35"
  bios          = "ovmf"
  description   = "OPNsense"
  tags          = ["firewall", "terraform"]

  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
  }

  cdrom {
    #file_id = "local:iso/OPNsense-26.1.2-dvd-amd64.iso"
    file_id = "none"
  }

  agent {
    enabled = true
    timeout = "15m"
    trim    = false
    type    = "virtio"
  }

  operating_system {
    type = "other"
  }

  memory {
    dedicated = 2048
  }

  #  efi_disk {
  #    datastore_id = var.datastore_id
  #    type         = "4m"
  #  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    iothread     = true
    size         = 25
  }

  initialization {
    ip_config {
      ipv4 {
        address = "10.0.0.2/24"
        gateway = "10.0.0.1"
      }

    }

    user_account {
      username = "astronuat"
    }
  }

  # WAN
  network_device {
    bridge = "vmbr0"
  }

  # MANAGEMENT
  network_device {
    bridge = "vmbr1"
  }

  # PROD
  network_device {
    bridge = "vmbr2"
  }

  # TEST
  network_device {
    bridge = "vmbr3"
  }

  #  # SECLAB
  #  network_device {
  #    bridge = "vmbr4"
  #  }

}

