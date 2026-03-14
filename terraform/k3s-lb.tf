# -------------------------------------------------------------------
# Triangulum LB — Nginx load balancer for k3s API server
# Prod network (vmbr2, 10.10.0.0/24)
#
# Balances traffic across k3s server nodes:
#   triangulum-alpha1 (10.10.0.100)
#   triangulum-alpha2 (10.10.0.101)
#
# Cloned from AlmaLinux 9 golden image (VM 9000)
# -------------------------------------------------------------------

resource "proxmox_virtual_environment_vm" "k3s_lb" {
  name          = "triangulum-lb"
  node_name     = "lab"
  vm_id         = 307
  on_boot       = true
  machine       = "q35"
  bios          = "ovmf"
  scsi_hardware = "virtio-scsi-single"
  tags          = ["k3s", "loadbalancer", "terraform", "triangulum"]

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
    cores   = 1
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = 1024
  }

  network_device {
    bridge = "vmbr2"
    model  = "virtio"
  }

  initialization {
    dns {
      servers = ["10.10.0.1"]
      domain  = "home.lab"
    }
    ip_config {
      ipv4 {
        address = "10.10.0.107/24"
        gateway = "10.10.0.1"
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

output "k3s_lb" {
  description = "k3s load balancer"
  value = {
    vm_id = proxmox_virtual_environment_vm.k3s_lb.vm_id
    ip    = "10.10.0.107"
  }
}
