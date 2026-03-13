# -------------------------------------------------------------------
# Triangulum — k3s cluster on Prod (vmbr2, 10.10.0.0/24)
#
# triangulum-alpha1  — server (control plane) — 10.10.0.100
# triangulum-alpha2  — server (control plane) — 10.10.0.101
# triangulum-beta1   — agent (worker)         — 10.10.0.102
# triangulum-beta2   — agent (worker)         — 10.10.0.103
# triangulum-beta3   — agent (worker)         — 10.10.0.104
# triangulum-beta4   — agent (worker)         — 10.10.0.105
#
# Cloned from AlmaLinux 9 golden image (VM 9000)
# -------------------------------------------------------------------

locals {
  k3s_nodes = {
    "triangulum-alpha1" = {
      vm_id  = 300
      ip     = "10.10.0.100/24"
      role   = "server"
      cores  = 2
      memory = 4096
    }
    "triangulum-alpha2" = {
      vm_id  = 301
      ip     = "10.10.0.101/24"
      role   = "server"
      cores  = 2
      memory = 4096
    }
    "triangulum-beta1" = {
      vm_id  = 302
      ip     = "10.10.0.102/24"
      role   = "agent"
      cores  = 2
      memory = 4096
    }
    "triangulum-beta2" = {
      vm_id  = 303
      ip     = "10.10.0.103/24"
      role   = "agent"
      cores  = 2
      memory = 4096
    }
    "triangulum-beta3" = {
      vm_id  = 304
      ip     = "10.10.0.104/24"
      role   = "agent"
      cores  = 2
      memory = 4096
    }
    "triangulum-beta4" = {
      vm_id  = 305
      ip     = "10.10.0.105/24"
      role   = "agent"
      cores  = 2
      memory = 4096
    }
  }
}

resource "proxmox_virtual_environment_vm" "k3s" {
  for_each = local.k3s_nodes

  name          = each.key
  node_name     = "lab"
  vm_id         = each.value.vm_id
  on_boot       = true
  machine       = "q35"
  bios          = "ovmf"
  scsi_hardware = "virtio-scsi-single"
  tags          = ["k3s", each.value.role, "terraform", "triangulum"]

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
    cores   = each.value.cores
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = each.value.memory
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
        address = each.value.ip
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

output "k3s_nodes" {
  description = "k3s cluster node details"
  value = {
    for name, vm in proxmox_virtual_environment_vm.k3s : name => {
      vm_id = vm.vm_id
      ip    = local.k3s_nodes[name].ip
      role  = local.k3s_nodes[name].role
    }
  }
}

