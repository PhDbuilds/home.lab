# -------------------------------------------------------------------
# Parrot OS — VM 103
# Jumphost
#
# Interfaces:
#   net0 → vmbr0 (192.168.1.245 — prod/management)
#   net1 → vmbr3 (192.168.50.101 — test)
#
# Note: UEFI (OVMF) with q35 machine type
#
# Import: terraform import proxmox_virtual_environment_vm.parrot lab/103
# -------------------------------------------------------------------

resource "proxmox_virtual_environment_vm" "parrot" {
  name      = "Parrot"
  node_name = "lab"
  vm_id     = 103
  on_boot   = false
  machine   = "q35"
  bios      = "ovmf"
  tags      = ["security", "jumphost", "terraform"]

  agent {
    enabled = true
  }

  cpu {
    cores   = 4
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = 8000
  }

  disk {
    datastore_id = "local-lvm"
    size         = 50
    interface    = "scsi0"
    iothread     = true
  }

  # net0 — vmbr0 (prod/management)
  network_device {
    bridge   = "vmbr0"
    model    = "virtio"
    firewall = true
  }

  # net1 — vmbr3 (test)
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
      started,
      keyboard_layout,
    ]
  }
}
