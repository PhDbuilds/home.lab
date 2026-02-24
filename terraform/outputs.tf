output "lab_vms" {
  description = "All Terraform-managed VMs"
  value = {
    pfsense = {
      id   = proxmox_virtual_environment_vm.pfsense.vm_id
      name = proxmox_virtual_environment_vm.pfsense.name
    }
    kali = {
      id   = proxmox_virtual_environment_vm.kali.vm_id
      name = proxmox_virtual_environment_vm.kali.name
    }
    parrot = {
      id   = proxmox_virtual_environment_vm.parrot.vm_id
      name = proxmox_virtual_environment_vm.parrot.name
    }
    rhel9_nessus = {
      id   = proxmox_virtual_environment_vm.rhel9_nessus.vm_id
      name = proxmox_virtual_environment_vm.rhel9_nessus.name
    }
    metasploitable = {
      id   = proxmox_virtual_environment_vm.metasploitable.vm_id
      name = proxmox_virtual_environment_vm.metasploitable.name
    }
    security_onion = {
      id   = proxmox_virtual_environment_vm.security_onion.vm_id
      name = proxmox_virtual_environment_vm.security_onion.name
    }
    ansible_control = {
      id   = proxmox_virtual_environment_vm.ansible_control.vm_id
      name = proxmox_virtual_environment_vm.ansible_control.name
    }
  }
}
