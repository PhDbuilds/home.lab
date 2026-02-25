output "lab_vms" {
  description = "All Terraform-managed VMs (space naming theme)"
  value = {
    polaris = {
      id   = proxmox_virtual_environment_vm.pfsense.vm_id
      name = proxmox_virtual_environment_vm.pfsense.name
    }
    corvus = {
      id   = proxmox_virtual_environment_vm.kali.vm_id
      name = proxmox_virtual_environment_vm.kali.name
    }
    sirius = {
      id   = proxmox_virtual_environment_vm.parrot.vm_id
      name = proxmox_virtual_environment_vm.parrot.name
    }
    rigel = {
      id   = proxmox_virtual_environment_vm.rhel9_nessus.vm_id
      name = proxmox_virtual_environment_vm.rhel9_nessus.name
    }
    phantom_alpha = {
      id   = proxmox_virtual_environment_vm.metasploitable.vm_id
      name = proxmox_virtual_environment_vm.metasploitable.name
    }
    vela = {
      id   = proxmox_virtual_environment_vm.security_onion.vm_id
      name = proxmox_virtual_environment_vm.security_onion.name
    }
    triangulum_alpha = {
      id   = proxmox_virtual_environment_vm.ansible_control.vm_id
      name = proxmox_virtual_environment_vm.ansible_control.name
    }
  }
}
