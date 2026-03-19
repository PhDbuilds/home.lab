variable "almalinux_vms" {
  description = "Map of AlmaLinux VM configurations"
  type = map(object({
    vm_id  = number
    bridge = string
  }))

  default = {
    "test-mgmt" = {
      vm_id  = 200
      bridge = "vmbr1"
    }
    "test-test" = {
      vm_id  = 201
      bridge = "vmbr3"
    }
    "test-prod" = {
      vm_id  = 202
      bridge = "vmbr2"
    }
  }
}

