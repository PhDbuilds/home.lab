# Proxmox Home Lab — Infrastructure as Code

## Naming Theme

VMs use a space-themed naming scheme.

| Host Name | VM ID | Role | Network |
|-----------|-------|------|---------|
| polaris | 100 | Firewall / router (OPNsense) | All bridges |
| sirius | 102 | Jumphost (AlmaLinux) | Management |

## Network Layout

All networking is virtual inside Proxmox using Open vSwitch bridges. OPNsense (polaris) acts as the sole router and firewall between all segments.

| Bridge | Network | Subnet | OPNsense Gateway | Policy |
|--------|---------|--------|-------------------|--------|
| vmbr0 | LAN | 192.168.1.0/24 | 192.168.1.2 (WAN) | Uplink to home router |
| vmbr1 | Management | 10.0.0.0/24 | 10.0.0.1 | Full access everywhere |
| vmbr2 | Prod | 10.10.0.0/24 | 10.10.0.1 | Internet only, no cross-network |
| vmbr3 | Security Lab | 10.20.0.0/24 | 10.20.0.1 | Fully isolated, intra-segment only |


## Prerequisites

1. Terraform installed on your workstation
2. `direnv` installed (`sudo dnf install direnv`)
3. Proxmox API token for the `terraform@pve` service account

## Setup

**1. Hook direnv into zsh** (one-time):

```bash
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
source ~/.zshrc
```

**2. Create `.envrc`** in the repo root (already in `.gitignore` — never commit this):

```bash
export PROXMOX_VE_ENDPOINT='https://proxmox:8006'
export PROXMOX_VE_USERNAME='terraform@pve'
export PROXMOX_VE_API_TOKEN='terraform@pve!terraform=YOUR_SECRET_HERE'
export PROXMOX_VE_INSECURE=true
```

**3. Allow it:**

```bash
direnv allow
```

direnv will automatically load these vars whenever you `cd` into the project and unload them when you leave.

## Day-to-Day Usage

```bash
# See what Terraform would change
terraform plan

# Apply changes
terraform apply

# See current state
terraform output
```
