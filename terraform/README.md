# Terraform

Provisions all VMs on Proxmox. Uses the `bpg/proxmox` provider and reads credentials from HashiCorp Vault via the `hashicorp/vault` provider.

## Secrets

Terraform reads Proxmox credentials from Vault at plan/apply time — no `.envrc` variables needed beyond `VAULT_ADDR`:

```hcl
data "vault_kv_secret_v2" "proxmox" {
  mount = "secret"
  name  = "terraform"
}
```

Expected keys in `secret/terraform`:
- `proxmox_ve_endpoint`
- `proxmox_ve_username`
- `proxmox_ve_api_token`
- `proxmox_ve_insecure`

## Files

| File | What it manages |
|------|-----------------|
| `main.tf` | Provider config (Proxmox + Vault) |
| `polaris.tf` | VM 100 — OPNsense firewall/router |
| `sirius.tf` | VM 102 — Jumphost |
| `vega.tf` | VM 101 — HashiCorp Vault server |
| `ansible-test-vms.tf` | VMs 200–202 — one test target per network segment |
| `k3s-cluster.tf` | VMs 300–305 — Triangulum k3s cluster (2 servers, 4 agents) |
| `k3s-db.tf` | VM 306 — PostgreSQL datastore for k3s |
| `k3s-lb.tf` | VM 307 — Nginx load balancer for the k3s API |

All VMs except polaris and sirius are full clones of the AlmaLinux 9 golden image (VM 9000). Cloud-init is used for network and user configuration at first boot.

## Usage

```bash
cd terraform/

# Authenticate to Vault first (reads VAULT_ADDR from .envrc)
vault login -method=userpass username=astronuat

# Preview changes
terraform plan

# Apply
terraform apply

# Show current outputs
terraform output
```
