# -------------------------------------------------------------------
# vega — VM 101
# Hashicorp Vault
#
# Note: UEFI (OVMF) with q35 machine type
# -------------------------------------------------------------------

resource "proxmox_virtual_environment_vm" "vega" {
  name          = "vega"
  node_name     = "lab"
  vm_id         = 101
  on_boot       = false
  machine       = "q35"
  bios          = "ovmf"
  scsi_hardware = "virtio-scsi-single"
  tags          = ["security", "vault", "terraform"]

  agent {
    enabled = true
    type    = "virtio"
  }

  clone {
    vm_id = 9000
    full  = true
  }

  operating_system {
    type = "l26"
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

  initialization {
    dns {
      servers = ["10.0.0.1"]
    }
    ip_config {
      ipv4 {
        address = "10.0.0.101/24"
        gateway = "10.0.0.1"
      }
    }
    user_account {
      username = "ansible"
      keys = [
        trimspace(file("~/.ssh/sirius_ansible.pub")),
      ]
    }
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

output "vega" {
  description = "Hashicorp Vault"
  value = {
    vm_id = proxmox_virtual_environment_vm.vega.vm_id
    ip    = "10.0.0.101"
  }
}
