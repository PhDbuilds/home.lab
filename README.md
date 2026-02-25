# Proxmox Home Lab — Infrastructure as Code

Terraform definitions for all VMs in the Proxmox home lab.

## Naming Theme

VMs use a space/astronomy naming scheme. Networks are named after galaxies.

| Star Name        | VM ID | Role                    |
|------------------|-------|-------------------------|
| polaris          | 113   | Firewall / router       |
| sirius           | 103   | Jumphost (Parrot OS)    |
| corvus           | 116   | Attack box (Kali)       |
| rigel            | 104   | Vulnerability scanner   |
| vela             | 107   | SIEM (Security Onion)   |
| triangulum-alpha | 109   | Ansible control node    |
| phantom-alpha    | 106   | Vulnerable target       |

## Network Layout

| Bridge | Galaxy     | Subnet           | Purpose              |
|--------|------------|------------------|----------------------|
| vmbr0  | Milky Way  | 192.168.1.0/24   | Prod / management    |
| vmbr1  | Phantom    | 192.168.255.0/24 | Vulnerable (air-gap) |
| vmbr2  | Sombrero   | 10.0.0.0/24      | DMZ                  |
| vmbr3  | Triangulum | 192.168.50.0/24  | Test                 |

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
terraform import proxmox_virtual_environment_vm.pfsense lab/113
terraform import proxmox_virtual_environment_vm.parrot lab/103
terraform import proxmox_virtual_environment_vm.kali lab/116
terraform import proxmox_virtual_environment_vm.rhel9_nessus lab/104
terraform import proxmox_virtual_environment_vm.security_onion lab/107
terraform import proxmox_virtual_environment_vm.ansible_control lab/109
terraform import proxmox_virtual_environment_vm.metasploitable lab/106
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
