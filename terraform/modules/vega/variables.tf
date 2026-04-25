variable "almalinux_vms" {
  description = "Map of AlmaLinux VM configurations"
  type = map(object({
    vm_id   = number
    bridge  = string
    address = string
    gateway = string
    cores   = optional(number, 2)
    mem     = optional(number, 3072)
  }))

  default = {
    "vega" = {
      vm_id   = 102
      bridge  = "vmbr1"
      address = "10.0.0.3/24"
      gateway = "10.0.0.1"
      mem     = 6144
    }

  }
}

