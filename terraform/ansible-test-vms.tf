# -------------------------------------------------------------------
# Ansible Test VMs — Cloned from AlmaLinux 9 Golden Image (VM 9000)
#
# One test VM per network segment for Ansible testing
# -------------------------------------------------------------------

locals {
  test_vms = {
    "ansible-test-mgmt" = {
      vm_id   = 200
      bridge  = "vmbr1"
      ip      = "10.0.0.50/24"
      gateway = "10.0.0.1"
      tags    = ["ansible", "test", "management", "terraform"]
    }
    "ansible-test-prod" = {
      vm_id   = 201
      bridge  = "vmbr2"
      ip      = "10.10.0.50/24"
      gateway = "10.10.0.1"
      tags    = ["ansible", "test", "prod", "terraform"]
    }
    "ansible-test-seclab" = {
      vm_id   = 202
      bridge  = "vmbr3"
      ip      = "10.20.0.50/24"
      gateway = "10.20.0.1"
      tags    = ["ansible", "test", "seclab", "terraform"]
    }
  }
}

resource "proxmox_virtual_environment_vm" "ansible_test" {
  for_each = local.test_vms

  name          = each.key
  node_name     = "lab"
  vm_id         = each.value.vm_id
  on_boot       = false
  machine       = "q35"
  bios          = "ovmf"
  scsi_hardware = "virtio-scsi-single"
  tags          = each.value.tags

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
    bridge = each.value.bridge
    model  = "virtio"
  }

  initialization {
    ip_config {
      ipv4 {
        address = each.value.ip
        gateway = each.value.gateway
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

output "ansible_test_vms" {
  description = "Ansible test VM details"
  value = {
    for name, vm in proxmox_virtual_environment_vm.ansible_test : name => {
      vm_id = vm.vm_id
      ip    = local.test_vms[name].ip
    }
  }
}
