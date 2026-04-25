terraform {
  required_version = ">= 1.14.7"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.98.1"
    }
  }
}

resource "proxmox_virtual_environment_vm" "alma-minimal" {
  for_each      = var.almalinux_vms
  name          = each.key
  vm_id         = each.value.vm_id
  node_name     = "lab"
  scsi_hardware = "virtio-scsi-single"
  machine       = "q35"
  bios          = "ovmf"
  description   = "Alma minimal machines"
  tags          = ["terraform", "monitoring"]

  cpu {
    cores   = each.value.cores
    sockets = 1
    type    = "host"
  }

  clone {
    vm_id = 9000
  }

  cdrom {
    file_id = "none"
  }

  operating_system {
    type = "l26"
  }

  memory {
    dedicated = each.value.mem
  }


  agent {
    enabled = true
    timeout = "15m"
    trim    = false
    type    = "virtio"
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    iothread     = true
    size         = 100
  }

  efi_disk {
    datastore_id = "local-lvm"
    type         = "4m"
  }

  initialization {

    user_account {
      username = "ansible"
    }
    ip_config {
      ipv4 {
        address = each.value.address
        gateway = each.value.gateway
      }
    }
  }

  # LAN
  network_device {
    bridge = each.value.bridge
  }

}

