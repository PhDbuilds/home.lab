terraform {
  required_version = ">= 1.14.7"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.98.1"
    }
  }
}

resource "proxmox_virtual_environment_vm" "hubble" {
  name          = "hubble"
  vm_id         = 105
  node_name     = "lab"
  scsi_hardware = "virtio-scsi-single"
  machine       = "q35"
  bios          = "ovmf"
  description   = "Ollama inference server"
  tags          = ["ollama", "terraform"]

  #  clone {
  #    vm_id = 9001
  #  }

  cpu {
    cores   = 6
    sockets = 1
    type    = "host"
  }

  cdrom {
    file_id = "none"
  }

  operating_system {
    type = "l26"
  }

  memory {
    dedicated = 8192
  }

  agent {
    enabled = true
    timeout = "15m"
    trim    = false
    type    = "virtio"
  }

  # OS disk
  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    iothread     = true
    size         = 60
  }

  # Models disk
  disk {
    datastore_id = "local-lvm"
    interface    = "scsi1"
    iothread     = true
    size         = 250
  }

  efi_disk {
    datastore_id = "local-lvm"
    type         = "4m"
  }

  vga {
    type = "serial0"
  }

  serial_device {
    device = "socket"
  }

  # GTX 1060 3GB — GP106 @ 01:00.0
  hostpci {
    device  = "hostpci0"
    mapping = "gtx1060-gpu"
    pcie    = true
    rombar  = true
  }

  # GP106 HDMI audio @ 01:00.1
  hostpci {
    device  = "hostpci1"
    mapping = "gtx1060-audio"
    pcie    = true
    rombar  = true
  }

  initialization {
    user_account {
      username = "astronuat"
      keys     = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIER93Zz4hF16OEjzZstU1JtYfTHDPAgq8SUG1VsjJXiw blnorris777@gmail.com"]
    }
    ip_config {
      ipv4 {
        address = "10.0.0.60/24"
        gateway = "10.0.0.1"
      }
    }
  }

  network_device {
    bridge = "vmbr1"
  }

  lifecycle {
    ignore_changes = [started]
  }
}
