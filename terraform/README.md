# Terraform

Provisions most VMs on Proxmox. Uses the `bpg/proxmox` provider and reads credentials from direnv

## Files

| File/Module | What it manages |
|------|-----------------|
| `main.tf` | Provider config (Proxmox + Vault) |
| `alma-full` | Full GUI machines (jumphost) | 
| `alma-minimal` | Almost every other machine in the lab |
| `OPNsense` | OPNsense router/firewall machine |

## Usage

```bash
cd terraform/

# Preview changes
terraform plan

# Apply
terraform apply

# Show current outputs
terraform output
```
