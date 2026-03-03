# -------------------------------------------------------------------
# sirius — VM 102
# Jumphost
#
# Note: UEFI (OVMF) with q35 machine type
# -------------------------------------------------------------------

resource "proxmox_virtual_environment_vm" "sirius" {
  name          = "sirius"
  node_name     = "lab"
  vm_id         = 102
  on_boot       = false
  machine       = "q35"
  bios          = "ovmf"
  scsi_hardware = "virtio-scsi-single"
  tags          = ["security", "jumphost", "terraform"]

  agent {
    enabled = true
    type    = "virtio"
  }

  operating_system {
    type = "l26"
  }

  cdrom {
    #file_id = "local:iso/AlmaLinux-10.1-x86_64-dvd.iso"
    file_id = "none"
  }

  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = 4096
  }

  efi_disk {
    datastore_id = "local-lvm"
    type         = "4m"
  }

  disk {
    datastore_id = "local-lvm"
    size         = 50
    interface    = "scsi0"
    iothread     = true
  }

  # Management only — reaches other networks through OPNsense
  network_device {
    bridge = "vmbr1"
    model  = "virtio"
  }

  lifecycle {
    ignore_changes = [
      disk,
      network_device,
      boot_order,
      started,
      keyboard_layout,
    ]
  }
}
