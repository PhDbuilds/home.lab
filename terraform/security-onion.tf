# -------------------------------------------------------------------
# Security Onion — VM 107
# SIEM / network security monitoring
#
# Interfaces:
#   net0 → vmbr0 (192.168.1.77 — management)
#   net1 → vmbr1 (SPAN/mirror port — captures traffic)
#
# Import: terraform import proxmox_virtual_environment_vm.security_onion lab/107
# -------------------------------------------------------------------

resource "proxmox_virtual_environment_vm" "security_onion" {
  name      = "SO"
  node_name = "lab"
  vm_id     = 107
  on_boot   = false
  scsi_hardware = "virtio-scsi-single"
  tags      = ["security", "siem", "terraform"]

  cpu {
    cores   = 4
    sockets = 1
    type    = "host"
  }

  operating_system {
    type = "l26"
  }

  memory {
    dedicated = 16180
  }

  disk {
    datastore_id = "local-lvm"
    size         = 200
    interface    = "scsi0"
    iothread     = true
  }

  # net0 — vmbr0 (management)
  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  # net1 — vmbr1 (SPAN mirror)
  network_device {
    bridge = "vmbr1"
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
