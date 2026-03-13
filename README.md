# Proxmox Home Lab — Infrastructure as Code

Fully automated homelab built on Proxmox using a three-layer IaC stack: (So far..)

```
Packer  →  builds the AlmaLinux 9 golden image (VM 9000)
Terraform  →  clones that image and provisions all VMs
Ansible  →  configures and hardens everything post-boot
```

Secrets for all three tools are stored in HashiCorp Vault (vega).

- [`packer/`](packer/) — Golden image build
- [`terraform/`](terraform/) — VM provisioning
- [`ansible/`](ansible/) — Post-boot configuration and hardening

---

## Naming Theme

VMs use a space-themed naming scheme.

## VM Inventory

| Host | VM ID | Role | Network | IP |
|------|-------|------|---------|----|
| polaris | 100 | Firewall / router (OPNsense) | All bridges | — |
| vega | 101 | HashiCorp Vault | Management | 10.0.0.101 |
| sirius | 102 | Jumphost | Management | 10.0.0.187 |
| ansible-test-mgmt | 200 | Ansible test target | Management | 10.0.0.50 |
| ansible-test-prod | 201 | Ansible test target | Prod | 10.10.0.50 |
| ansible-test-seclab | 202 | Ansible test target | Security Lab | 10.20.0.50 |
| triangulum-alpha1 | 300 | k3s server (control plane) | Prod | 10.10.0.100 |
| triangulum-alpha2 | 301 | k3s server (control plane) | Prod | 10.10.0.101 |
| triangulum-beta1 | 302 | k3s agent (worker) | Prod | 10.10.0.102 |
| triangulum-beta2 | 303 | k3s agent (worker) | Prod | 10.10.0.103 |
| triangulum-beta3 | 304 | k3s agent (worker) | Prod | 10.10.0.104 |
| triangulum-beta4 | 305 | k3s agent (worker) | Prod | 10.10.0.105 |
| triangulum-db | 306 | PostgreSQL (k3s datastore) | Prod | 10.10.0.106 |
| triangulum-lb | 307 | Nginx (k3s API load balancer) | Prod | 10.10.0.107 |

VM 9000 is the AlmaLinux 9 golden image template built by Packer.

## Network Layout

All networking is virtual inside Proxmox using Open vSwitch bridges. OPNsense (polaris) acts as the sole router and firewall between all segments.

| Bridge | Network | Subnet | OPNsense Gateway | Policy |
|--------|---------|--------|-------------------|--------|
| vmbr0 | LAN | 192.168.1.0/24 | 192.168.1.2 | Uplink to home router |
| vmbr1 | Management | 10.0.0.0/24 | 10.0.0.1 | Full access everywhere |
| vmbr2 | Prod | 10.10.0.0/24 | 10.10.0.1 | Internet only, no cross-network |
| vmbr3 | Security Lab | 10.20.0.0/24 | 10.20.0.1 | Fully isolated, intra-segment only |

## Prerequisites

- Terraform >= 1.5.0
- Packer >= 1.9.0
- Ansible >= 2.15
- `direnv` (`sudo dnf install direnv`)
- HashiCorp Vault running at `http://10.0.0.101:8200` (vega)
- AlmaLinux 9 minimal ISO uploaded to Proxmox storage

## Setup

**1. Hook direnv into zsh** (one-time):

```bash
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
source ~/.zshrc
```

**2. The `.envrc`** in the repo root sets `VAULT_ADDR` (already in `.gitignore` — never commit this):

```bash
export VAULT_ADDR='http://10.0.0.101:8200'
```

**3. Allow it and authenticate to Vault:**

```bash
direnv allow
vault login -method=userpass username=astronuat
```

All other secrets (Proxmox API token, k3s token, database credentials) are read from Vault at runtime by each tool.
