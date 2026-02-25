# -------------------------------------------------------------------
# Triangulum VMs — vmbr3 (192.168.50.0/24 — test network)
#
# -------------------------------------------------------------------

locals {
  triangulum_vms = {
    "triangulum-alpha" = { vm_id = 109, tags = ["ansible", "terraform"] }
    "triangulum-beta"  = { vm_id = 9000, tags = ["k3s", "terraform"] }
    "triangulum-gamma" = { vm_id = 9001, tags = ["k3s", "terraform"] }
    "triangulum-delta" = { vm_id = 9002, tags = ["k3s", "terraform"] }
  }
}

resource "proxmox_virtual_environment_vm" "triangulum" {
  for_each      = local.triangulum_vms
  name          = each.key
  node_name     = "lab"
  vm_id         = each.value.vm_id
  on_boot       = false
  machine       = "q35"
  bios          = "ovmf"
  scsi_hardware = "virtio-scsi-single"
  tags          = each.value.tags

  agent {
    enabled = true
    type    = "virtio"
  }

  operating_system {
    type = "l26"
  }

  cpu {
    cores   = 3
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = 2048
  }

  efi_disk {
    datastore_id      = "local-lvm"
    type              = "4m"
    pre_enrolled_keys = true
  }

  disk {
    datastore_id = "local-lvm"
    size         = 32
    interface    = "scsi0"
    iothread     = true
    ssd          = true
    cache        = "writeback"
    discard      = "on"
  }

  network_device {
    bridge = "vmbr3"
    model  = "virtio"
  }

  lifecycle {
    ignore_changes = [
      disk,
      network_device,
      boot_order,
      cdrom,
      efi_disk,
      started,
      keyboard_layout,
    ]
  }
}
