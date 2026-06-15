variable "almalinux_vms" {
  description = "Map of AlmaLinux VM configurations"
  type = map(object({
    vm_id   = number
    bridge  = string
    address = string
    gateway = string
    cores   = optional(number, 2)
    mem     = optional(number, 3072)
    size    = optional(number, 50)
  }))

  default = {

    // Test machines
    //    "test-mgmt" = {
    //      vm_id   = 200
    //      bridge  = "vmbr1"
    //      address = "10.0.0.7/24"
    //      gateway = "10.0.0.1"
    //    }
    //    "test-test" = {
    //      vm_id   = 201
    //      bridge  = "vmbr3"
    //      address = "10.10.0.7/24"
    //      gateway = "10.10.0.1"
    //    }
    //    "test-prod" = {
    //      vm_id   = 202
    //      bridge  = "vmbr2"
    //      address = "10.20.0.7/24"
    //      gateway = "10.20.0.1"
    //    }
    "k8s-playground" = {
      vm_id   = 203
      bridge  = "vmbr1"
      address = "10.0.0.70/24"
      gateway = "10.0.0.1"
    }
    // "lfs-build" = {
    //   vm_id   = 777
    //   bridge  = "vmbr1"
    //   address = "10.0.0.99/24"
    //   gateway = "10.0.0.1"
    //   cores   = 4
    //   mem     = 8192
    // }
    "alpha-cen" = {
      vm_id   = 106
      bridge  = "vmbr1"
      address = "10.0.0.61/24"
      gateway = "10.0.0.1"
      cores   = 2
      mem     = 2048
    }
    "proxima-cen" = {
      vm_id   = 107
      bridge  = "vmbr1"
      address = "10.0.0.62/24"
      gateway = "10.0.0.1"
      cores   = 2
      mem     = 2048
    }
  }
}
