variable "fcos_vms" {
  description = "Map of FCOS Kubernetes node configurations."
  type = map(object({
    vm_id  = number
    mac    = string
    bridge = optional(string, "vmbr1")
    cores  = optional(number, 2)
    mem    = optional(number, 4096)
    size   = optional(number, 50)
  }))
  default = {
    "triangulum-alpha" = {
      vm_id = 500
      mac   = "BC:24:11:00:01:10"
      cores = 4
    }
    "triangulum-beta" = {
      vm_id = 501
      mac   = "BC:24:11:00:01:11"
    }
    "triangulum-gamma" = {
      vm_id = 502
      mac   = "BC:24:11:00:01:12"
    }
  }
}
