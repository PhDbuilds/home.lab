# Proxmox Home Lab — Infrastructure as Code

Fully (almost) automated homelab built on Proxmox using IaC stack

```
Terraform  →  clones that image and provisions all VMs
Ansible  →  configures and hardens everything post-boot
```

Secrets for all tools are stored in direnv/.envrc.

- [`terraform/`](terraform/) — VM provisioning
- [`ansible/`](ansible/) — Post-boot configuration and hardening

---

## Naming Theme

VMs use a space-themed naming scheme. Mostly..

## VM Inventory

| Host | VM ID | Role | Network | IP |
|------|-------|------|---------|----|
| polaris | 100 | Firewall / router (OPNsense) | All bridges | — |
| sirius | 101 | Jumphost | MGMT | 10.0.0.7 |
| pulsar | 900 | PXE server | MGMT | 10.0.0.8 |

## Network Layout

All networking is virtual inside Proxmox using Open vSwitch bridges. OPNsense (polaris) acts as the sole router and firewall between all segments.

| Bridge | Network | Subnet | OPNsense Gateway | Policy |
|--------|---------|--------|-------------------|--------|
| vmbr0 | LAN | 192.168.1.0/24 | 192.168.1.2 | Uplink to home router |
| vmbr1 | Management | 10.0.0.0/24 | 10.0.0.1 | Full access everywhere |
| vmbr2 | Prod | 10.10.0.0/24 | 10.10.0.1 | Internet only, no cross-network |
| vmbr3 | Test | 10.20.0.0/24 | 10.20.0.1 | Test network |

## Prerequisites

- Terraform >= 1.5.0
- Ansible >= 2.15
- `direnv` (`sudo dnf install direnv`)

## Setup

**1. Hook direnv into zsh** (one-time):

```bash
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
source ~/.zshrc
```

**3. Allow direnv** (each time change is made to .envrc)
```bash
direnv allow
```
