terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.78"
    }
  }
}

resource "proxmox_virtual_environment_vm" "vm" {
  name          = var.name
  node_name     = var.node_name
  vm_id         = var.vm_id
  on_boot       = var.on_boot
  machine       = "q35"
  bios          = "ovmf"
  scsi_hardware = "virtio-scsi-single"
  tags          = concat(var.tags, ["terraform"])

  agent {
    enabled = true
    type    = "virtio"
  }

  clone {
    vm_id = var.template_vm_id
    full  = true
  }

  operating_system {
    type = "l26"
  }

  cpu {
    cores   = var.cores
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = var.memory
  }

  efi_disk {
    datastore_id = "local-lvm"
    type         = "4m"
  }

  disk {
    datastore_id = "local-lvm"
    size         = var.disk_size
    interface    = "scsi0"
    iothread     = true
  }

  network_device {
    bridge = var.bridge
    model  = "virtio"
  }

  initialization {
    dns {
      servers = [var.dns_server]
      domain  = "home.lab"
    }
    ip_config {
      ipv4 {
        address = var.ip
        gateway = var.gateway
      }
    }
  }

  lifecycle {
    ignore_changes = [
      disk,
      network_device,
      boot_order,
      started,
      keyboard_layout,
    ]
  }
}
