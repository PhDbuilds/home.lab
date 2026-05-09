terraform {
  required_version = ">= 1.14.7"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.98.1"
    }
  }
}

resource "proxmox_virtual_environment_vm" "pihole" {
  name          = "pihole"
  vm_id         = 401
  node_name     = "lab"
  scsi_hardware = "virtio-scsi-single"
  machine       = "q35"
  bios          = "ovmf"
  description   = "PiHole DNS running on FCOS"
  tags          = ["terraform", "fcos", "pihole"]

  #boot_order = ["net0", "scsi0"]

  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = 4096
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    iothread     = true
    size         = 20
  }

  efi_disk {
    datastore_id = "local-lvm"
    type         = "4m"
  }

  network_device {
    bridge = "vmbr1"
  }

  operating_system {
    type = "l26"
  }
}
