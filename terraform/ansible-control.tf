# -------------------------------------------------------------------
# Ansible Control Node — VM 109
# RHEL9 — Ansible control machine
#
# Interfaces:
#   net0 → vmbr3 (192.168.50.10 — test network)
#
# Note: UEFI (OVMF) with q35 machine type, has EFI disk
#
# Import: terraform import proxmox_virtual_environment_vm.ansible_control lab/qemu/109
# -------------------------------------------------------------------

resource "proxmox_virtual_environment_vm" "ansible_control" {
  name      = "control"
  node_name = "lab"
  vm_id     = 109
  on_boot   = false
  machine   = "q35"
  bios      = "ovmf"
  tags      = ["ansible", "terraform"]

  agent {
    enabled = true
  }

  cpu {
    cores   = 3
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = 2048
  }

  # EFI disk
  efi_disk {
    datastore_id        = "local-lvm"
    type                = "4m"
    pre_enrolled_keys   = true
  }

  # Boot disk
  disk {
    datastore_id = "local-lvm"
    size         = 32
    interface    = "scsi0"
    iothread     = true
    ssd          = true
    cache        = "writeback"
    discard      = "on"
  }

  # net0 — vmbr3 (test/ansible)
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
    ]
  }
}
