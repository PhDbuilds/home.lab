# -------------------------------------------------------------------
# polaris — VM 100
# Firewall/router for the lab
#
# Interfaces:
# vmbr0 	LAN 	192.168.1.0/24 	WAN (uplink to home router) 	Proxmox host management, upstream internet
# vmbr1 	Management 	10.0.0.0/24 	LAN (gateway 10.0.0.1) 	Infrastructure: monitoring, Ansible, DNS, logging
# vmbr2 	Prod 	10.10.0.0/24 	PROD (gateway 10.10.0.1) 	Workloads: k3s, self-hosted services
# vmbr3 	Security Lab 	10.20.0.0/24 	SECLAB (gateway 10.20.0.1) 	Isolated: vulnerable VMs, AD lab, attack boxes
#
# -------------------------------------------------------------------

resource "proxmox_virtual_environment_vm" "opnsense" {
  name          = "polaris"
  node_name     = "lab"
  vm_id         = 100
  on_boot       = true
  scsi_hardware = "virtio-scsi-single"
  tags          = ["firewall", "terraform"]

  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
  }

  cdrom {
    #file_id = "local:iso/OPNsense-26.1.2-dvd-amd64.iso"
    file_id = "none"
  }

  operating_system {
    type = "other"
  }


  agent {
    enabled = true
    timeout = "15m"
    trim    = false
    type    = "virtio"
  }

  memory {
    dedicated = 2048
  }

  disk {
    datastore_id = "local-lvm"
    size         = 32
    interface    = "scsi0"
    iothread     = true
  }

  # WAN — vmbr0
  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  # LAN — vmbr1 (Management)
  network_device {
    bridge = "vmbr1"
    model  = "virtio"
  }

  # PROD — vmbr2 (Prod)
  network_device {
    bridge = "vmbr2"
    model  = "virtio"
  }

  # SECLAB — vmbr3 (Security Lab)
  network_device {
    bridge = "vmbr3"
    model  = "virtio"
  }

  lifecycle {
    ignore_changes = [
      disk,
      network_device,
      boot_order,
      started,
      keyboard_layout,
    ]
  }
}
