# -------------------------------------------------------------------
# Kali Linux — VM 116
# Primary attack box / purple team
#
# Interfaces:
#   net0 → vmbr0 (192.168.1.20 — prod/management)
#   net1 → vmbr1 (vulnerable network)
#
# Import: terraform import proxmox_virtual_environment_vm.kali lab/qemu/116
# -------------------------------------------------------------------

resource "proxmox_virtual_environment_vm" "kali" {
  name      = "kal1"
  node_name = "lab"
  vm_id     = 116
  on_boot   = false
  tags      = ["security", "attack", "terraform"]

  cpu {
    cores   = 6
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = 12288
  }

  disk {
    datastore_id = "local-lvm"
    size         = 101
    interface    = "scsi0"
    iothread     = true
    ssd          = true
  }

  # net0 — vmbr0 (prod/management)
  network_device {
    bridge   = "vmbr0"
    model    = "virtio"
    firewall = true
  }

  # net1 — vmbr1 (vulnerable/air-gapped)
  network_device {
    bridge   = "vmbr1"
    model    = "virtio"
    firewall = true
  }

  lifecycle {
    ignore_changes = [
      disk,
      network_device,
      boot_order,
    ]
  }
}
