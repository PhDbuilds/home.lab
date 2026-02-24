# -------------------------------------------------------------------
# Metasploitable 2 — VM 106
# Intentionally vulnerable target
#
# Interfaces:
#   net0 → vmbr1 (192.168.255.10 — vulnerable network only)
#
# Note: Uses IDE disk (not SCSI) — imported VM from OVA
#
# Import: terraform import proxmox_virtual_environment_vm.metasploitable lab/qemu/106
# -------------------------------------------------------------------

resource "proxmox_virtual_environment_vm" "metasploitable" {
  name      = "Metasploitable2"
  node_name = "lab"
  vm_id     = 106
  on_boot   = false
  tags      = ["security", "target", "terraform"]

  cpu {
    cores   = 2
    sockets = 1
  }

  memory {
    dedicated = 2048
  }

  disk {
    datastore_id = "local-lvm"
    size         = 8
    interface    = "ide0"
  }

  # net0 — vmbr1 (vulnerable/air-gapped)
  network_device {
    bridge = "vmbr1"
    model  = "virtio"
  }

  lifecycle {
    ignore_changes = [
      disk,
      network_device,
      boot_order,
    ]
  }
}
