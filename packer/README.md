# Packer

Builds the AlmaLinux 9 golden image (VM 9000) on Proxmox. All Terraform-managed VMs are full clones of this template, with the exception of the jumphost (sirius), which usees the DVD GUI version of AlmaLinux 10 instead of the minimal version used here.

## What it builds

A hardened AlmaLinux 9 minimal install with:
- System fully updated
- Base tooling (`vim`, `curl`, `git`, `tmux`, `jq`, etc.)
- `qemu-guest-agent` and `cloud-init` enabled
- `ansible` user with sudo and your SSH public key
- SSH hardened (no root login, no passwords, key-only)
- `firewalld` enabled (SSH only)
- SELinux enforcing
- Machine-specific identifiers scrubbed (machine-id, hostname, SSH host keys) so each clone boots fresh

## Secrets

Packer reads Proxmox credentials and the SSH public key path from Vault using the native `vault()` function:

```hcl
locals {
  proxmox_url         = vault("secret/data/packer", "pkr_var_proxmox_url")
  proxmox_username    = vault("secret/data/packer", "pkr_var_proxmox_username")
  proxmox_token       = vault("secret/data/packer", "pkr_var_proxmox_token")
  ssh_public_key_path = vault("secret/data/packer", "pkr_var_ssh_public_key_path")
}
```

`VAULT_ADDR` must be set (via `.envrc` + `direnv allow` in the repo root) and you must be authenticated before running a build.

## Prerequisites

- AlmaLinux 9 minimal ISO uploaded to Proxmox (`local:iso/AlmaLinux-9-latest-x86_64-minimal.iso`)
- Vault authenticated (`vault login`)

## Usage

```bash
cd packer/alma-minimal/

# Install the Proxmox plugin (first time)
packer init .

# Validate config
packer validate .

# Build and register the template
packer build .
```

## Files

| File | Purpose |
|------|---------|
| `almalinux-golden.pkr.hcl` | Main Packer config — VM spec, boot command, build steps |
| `http/ks.cfg` | Kickstart file served over HTTP during install |
| `scripts/provision.sh` | Post-install provisioning script run by Packer over SSH |

## Notes

- `cpu_type = "host"` is required. Omitting it causes an immediate kernel panic on boot. This took way too long to figure out..
