variable "proxmox_password" {
  type    = string
  default = var.TF_VAR_proxmox_api_token
}

variable "proxmox_username" {
  type    = string
  default = "root@pve"
}

variable "proxmox_url" {
  type = string
  default = "https://192.168.1.180:8006/api2/json/"
}

source "proxmox-clone" "alma" {
  clone_vm                 = "alma-minimal"
  cores                    = 1
  insecure_skip_tls_verify = true
  memory                   = 2048
  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }
  node                 = "pve"
  os                   = "l26"
  password             = "${var.proxmox_password}"
  pool                 = "api-users"
  proxmox_url          = "${var.proxmox_url}"
  sockets              = 1
  ssh_username         = "astronuat"
  template_description = "image made from cloud-init image"
  template_name        = "alma-scaffolding"
  username             = "${var.proxmox_username}"
}

build {
  sources = ["source.proxmox-clone.debian"]
}

