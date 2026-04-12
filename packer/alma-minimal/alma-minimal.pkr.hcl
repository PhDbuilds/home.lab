packer {
  required_plugins {
    proxmox = {
      version = ">= 1.2.2"
      source = "github.com/hashicorp/proxmox"
    }
  }
}

# VARIABLES
variable "proxmox_node" {
  type = string
  default = "lab"
}

variable "vm_id" {
  type = number
  default = 9000
}

variable "storage_pool" {
  type = string
  default = "local-lvm"
}


variable "proxmox_username" {
  type    = string
  default = "terraform@pve!packer-token"
}

variable "proxmox_url" {
  type = string
  default = "https://192.168.1.180:8006/api2/json/"
}

variable "proxmox_api_token" {
  type = string
}

# SOURCE
source "proxmox-iso" "alma-minimal-golden" {
  proxmox_url          = "${var.proxmox_url}"
  username             = "${var.proxmox_username}"
  token             = "${var.proxmox_api_token}"
  node                 = "${var.proxmox_node}"


  vm_id = "${var.vm_id}"
  vm_name = "almalinux9-golden"
  machine = "q35"
  bios = "ovmf"

  efi_config {
    efi_storage_pool = "${var.storage_pool}"
    pre_enrolled_keys = false
  }

  template_name        = "alma-scaffolding"
  template_description = "AlmaLinux 9 Golden Image"
  os                   = "l26"
  qemu_agent = true

  cores                    = 2
  sockets              = 1
  memory                   = 2048
  insecure_skip_tls_verify = true
  cpu_type = "host"

  scsi_controller = "virtio-scsi-single"

  disks {
    type = "scsi"
    disk_size = "20G"
    storage_pool = "${var.storage_pool}"
  }

  network_adapters {
    bridge = "vmbr1"
    model  = "virtio"
  }

  boot_iso {
    iso_file                 = "local:iso/AlmaLinux-9-latest-x86_64-minimal.iso"
    unmount = true
    iso_checksum = "none"
  }

  ssh_username         = "root"
  ssh_password = "packer"
  ssh_timeout = "20m"

  http_directory = "./http"

  boot_command = [
    "<wait><up><wait3>",
    "e<wait2>",
    "<down><down><end><wait>",
    " inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg",
    "<leftCtrlOn>x<leftCtrlOff>"
  ]
  boot_wait = "20s"

  cloud_init = true
  cloud_init_storage_pool = "${var.storage_pool}"
}

build {
  sources = ["source.proxmox-iso.alma-minimal-golden"]
}

