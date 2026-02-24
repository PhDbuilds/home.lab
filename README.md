# Proxmox Home Lab — Infrastructure as Code

Terraform definitions for all VMs in the Proxmox home lab.

## Network Layout

| Bridge | pfSense Iface | Subnet           | Purpose              |
|--------|---------------|------------------|----------------------|
| vmbr0  | WAN           | 192.168.1.0/24   | Prod / management    |
| vmbr1  | —             | 192.168.255.0/24 | Vulnerable (air-gap) |
| vmbr2  | OPT           | 10.0.0.0/24      | Dev                  |
| vmbr3  | LAN           | 192.168.50.0/24  | Test                 |

## Prerequisites

1. Terraform installed on your workstation
2. Proxmox API token (see below)
3. SSH key access to Proxmox host

## Setup

```bash
# Environment variables (add to ~/.zshrc)
export PROXMOX_VE_ENDPOINT='https://proxmox:8006'
export PROXMOX_VE_API_TOKEN='terraform@pve!terraform-token=YOUR_TOKEN'
export PROXMOX_VE_INSECURE=true

# SSH agent (provider needs this to upload files)
eval $(ssh-agent)
ssh-add ~/.ssh/id_ed25519
```

## Importing Existing VMs

These VMs already exist in Proxmox. Terraform needs to "import" them
so it knows they exist and can track their state.

```bash
cd terraform/
terraform init
terraform import proxmox_virtual_environment_vm.jump lab/qemu/103
terraform import proxmox_virtual_environment_vm.nessus lab/qemu/104
terraform import proxmox_virtual_environment_vm.rhel lab/qemu/109
terraform import proxmox_virtual_environment_vm.pfsense lab/qemu/113
terraform import proxmox_virtual_environment_vm.kali lab/qemu/116
```

After importing, run `terraform plan` — the goal is **zero changes**.
If Terraform wants to change something, adjust the `.tf` file to match
what actually exists, then plan again until it's clean.

## Day-to-Day Usage

```bash
# See what Terraform would change
terraform plan

# Apply changes
terraform apply

# See current state
terraform output
```
