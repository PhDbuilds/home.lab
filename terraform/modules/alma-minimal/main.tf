terraform {
  required_version = "1.14.7"
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
  tags          = ["terraform"]

  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
  }

  cdrom {
    #file_id = "local:iso/AlmaLinux-10.1-x86_64-dvd.iso"
    file_id = "none"

  }

  operating_system {
    type = "l26"
  }

  memory {
    dedicated = 3072
  }


  agent {
    enabled = true
    timeout = "15m"
    trim    = false
    type    = "virtio"
  }


  #  efi_disk {
  #    datastore_id = var.datastore_id
  #    type         = "4m"
  #  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    iothread     = true
    size         = 50
  }

  efi_disk {
    datastore_id = "local-lvm"
    type         = "4m"
  }

  initialization {

    user_account {
      username = "astronuat"
    }
  }

  # LAN
  network_device {
    bridge = each.value.bridge
  }


}

