variable "almalinux_vms" {
  description = "Map of AlmaLinux VM configurations"
  type = map(object({
    vm_id   = number
    bridge  = string
    address = string
    gateway = string
  }))

  default = {
    "test-mgmt" = {
      vm_id   = 200
      bridge  = "vmbr1"
      address = "10.0.0.7/24"
      gateway = "10.0.0.1"
    }
    "test-test" = {
      vm_id   = 201
      bridge  = "vmbr3"
      address = "10.10.0.7/24"
      gateway = "10.10.0.1"
    }
    "test-prod" = {
      vm_id   = 202
      bridge  = "vmbr2"
      address = "10.20.0.7/24"
      gateway = "10.20.0.1"
    }
  }
}

