# -------------------------------------------------------------------
# triangulum-gamme — VM 9001
# Alma — K3s worker machine
#
# Interfaces:
#   net0 → vmbr3 → Triangulum (192.168.50.101 — test network)
#
# Note: UEFI (OVMF) with q35 machine type, has EFI disk
#
# -------------------------------------------------------------------

resource "proxmox_virtual_environment_vm" "triangulum_gamma" {
  name          = "triangulum-gamma"
  node_name     = "lab"
  vm_id         = 9001
  on_boot       = false
  machine       = "q35"
  bios          = "ovmf"
  scsi_hardware = "virtio-scsi-single"
  tags          = ["k3s", "terraform"]


  #  cdrom {
  #    file_id   = "local:iso/AlmaLinux-9-latest-x86_64-minimal.iso"
  #    interface = "ide2"
  #  }

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

  # EFI disk
  efi_disk {
    datastore_id      = "local-lvm"
    type              = "4m"
    pre_enrolled_keys = true
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
      started,
      keyboard_layout,
    ]
  }
}
