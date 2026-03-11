# -------------------------------------------------------------------
# Triangulum DB — PostgreSQL datastore for k3s cluster
# Prod network (vmbr2, 10.10.0.0/24)
#
# Cloned from AlmaLinux 9 golden image (VM 9000)
# -------------------------------------------------------------------

resource "proxmox_virtual_environment_vm" "k3s_db" {
  name          = "triangulum-db"
  node_name     = "lab"
  vm_id         = 306
  on_boot       = true
  machine       = "q35"
  bios          = "ovmf"
  scsi_hardware = "virtio-scsi-single"
  tags          = ["k3s", "database", "terraform", "triangulum"]

  clone {
    vm_id = 9000
    full  = true
  }

  agent {
    enabled = true
    type    = "virtio"
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
    dedicated = 2048
  }

  network_device {
    bridge = "vmbr2"
    model  = "virtio"
  }

  initialization {
    dns {
      servers = ["10.10.0.1"]
    }
    ip_config {
      ipv4 {
        address = "10.10.0.106/24"
        gateway = "10.10.0.1"
      }
    }
    user_account {
      username = "ansible"
      keys = [
        file("~/.ssh/id_ed25519.pub"),
        file("~/.ssh/sirius_ansible.pub"),
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

output "k3s_db" {
  description = "k3s PostgreSQL datastore"
  value = {
    vm_id = proxmox_virtual_environment_vm.k3s_db.vm_id
    ip    = "10.10.0.106"
  }
}
