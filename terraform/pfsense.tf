# -------------------------------------------------------------------
# pfSense — VM 113
# Firewall/router for the lab
#
# Interfaces:
#   WAN  → vmbr0 (192.168.1.0/24)
#   LAN  → vmbr3 (192.168.50.0/24)  gateway 192.168.50.1
#   OPT  → vmbr2 (10.0.0.0/24)      gateway 10.0.0.1
#
# Import: terraform import proxmox_virtual_environment_vm.pfsense lab/113
# -------------------------------------------------------------------

resource "proxmox_virtual_environment_vm" "pfsense" {
  name      = "pfSense"
  node_name = "lab"
  vm_id     = 113
  on_boot   = true
  scsi_hardware = "virtio-scsi-single"
  tags      = ["firewall", "terraform"]

  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
  }

  operating_system {
    type = "l26"
  }

  memory {
    dedicated = 2048
  }

  disk {
    datastore_id = "local-lvm"
    size         = 32
    interface    = "scsi0"
    iothread     = true
  }

  # WAN — vmbr0
  network_device {
    bridge = "vmbr0"
    model  = "e1000"
  }

  # LAN — vmbr3 (Test/Ansible)
  network_device {
    bridge = "vmbr3"
    model  = "virtio"
  }

  # OPT — vmbr2 (DMZ)
  network_device {
    bridge = "vmbr2"
    model  = "virtio"
  }

  lifecycle {
    ignore_changes = [
      disk,
      network_device,
      boot_order,
      cdrom,
    ]
  }
}
