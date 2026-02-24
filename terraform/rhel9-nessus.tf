# -------------------------------------------------------------------
# RHEL9 Nessus — VM 104
# Vulnerability scanner
#
# Interfaces:
#   net0 → vmbr0 (192.168.1.6 — prod)
#   net1 → vmbr1 (192.168.255.40 — vulnerable)
#   net2 → vmbr2 (DMZ)
#
# Note: UEFI (OVMF) with q35 machine type, has EFI disk
#
# Import: terraform import proxmox_virtual_environment_vm.rhel9_nessus lab/104
# -------------------------------------------------------------------

resource "proxmox_virtual_environment_vm" "rhel9_nessus" {
  name      = "RHEL9-Nessus"
  node_name = "lab"
  vm_id     = 104
  on_boot   = false
  machine   = "q35"
  bios      = "ovmf"
  tags      = ["security", "scanner", "terraform"]

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

  # net0 — vmbr0 (prod)
  network_device {
    bridge   = "vmbr0"
    model    = "virtio"
    firewall = true
  }

  # net1 — vmbr1 (vulnerable)
  network_device {
    bridge   = "vmbr1"
    model    = "virtio"
    firewall = true
  }

  # net2 — vmbr2 (DMZ)
  network_device {
    bridge   = "vmbr2"
    model    = "virtio"
    firewall = true
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
