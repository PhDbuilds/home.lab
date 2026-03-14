variable "name" {
  type        = string
  description = "VM name and hostname"
}

variable "vm_id" {
  type        = number
  description = "Proxmox VM ID"
}

variable "ip" {
  type        = string
  description = "Static IPv4 address with CIDR (e.g. \"10.0.0.100/24\")"
}

variable "tags" {
  type        = list(string)
  description = "Proxmox tags — \"terraform\" is added automatically"
}

variable "on_boot" {
  type    = bool
  default = false
}

variable "cores" {
  type    = number
  default = 2
}

variable "memory" {
  type        = number
  default     = 4096
  description = "RAM in MB"
}

variable "disk_size" {
  type        = number
  default     = 30
  description = "Root disk size in GB"
}

variable "bridge" {
  type        = string
  default     = "vmbr1"
  description = "Proxmox bridge (vmbr1=mgmt, vmbr2=prod)"
}

variable "gateway" {
  type    = string
  default = "10.0.0.1"
}

variable "dns_server" {
  type    = string
  default = "10.0.0.1"
}

variable "template_vm_id" {
  type        = number
  default     = 9001
  description = "Source template to clone (9001 = AlmaLinux 9 golden image)"
}

variable "node_name" {
  type    = string
  default = "lab"
}
