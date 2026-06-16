terraform {
  required_version = ">= 1.14.7"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.98.1"
    }
  }
}

resource "proxmox_virtual_environment_vm" "fcos" {
  for_each = var.fcos_vms

  name          = each.key
  vm_id         = each.value.vm_id
  node_name     = "lab"
  description   = "FCOS Kubernetes node (PXE-provisioned)"
  tags          = ["terraform", "fcos", "k8s"]
  scsi_hardware = "virtio-scsi-single"
  machine       = "q35"
  bios          = "ovmf"

  boot_order = ["scsi0", "net0"]

  cpu {
    cores   = each.value.cores
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = each.value.mem
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    iothread     = true
    size         = each.value.size
  }

  efi_disk {
    datastore_id = "local-lvm"
    type         = "4m"
  }

  network_device {
    bridge      = each.value.bridge
    mac_address = each.value.mac
  }

  agent {
    enabled = true
    timeout = "15m"
    trim    = false
    type    = "virtio"
  }

  operating_system {
    type = "l26"
  }

  lifecycle {
    ignore_changes = [started]
  }
}
