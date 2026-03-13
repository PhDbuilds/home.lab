# Ansible

Configures and hardens all VMs after Terraform provisions them. Connects as the `ansible` user (key-only, set up by the Packer golden image).

## Collections

Managed via `requirements.yml`. Install with:

```bash
ansible-galaxy collection install -r requirements.yml
```

| Collection | Purpose |
|-----------|---------|
| `devsec.hardening` | OS and SSH hardening (CIS-aligned) |
| `ansible.posix` | firewalld, SELinux, seboolean |
| `community.general` | SELinux port management (`seport`) |
| `community.hashi_vault` | Vault KV lookups at playbook runtime |

## Inventory

`inventory/hosts.yml` — all hosts grouped by role and network segment:

| Group | Hosts | Purpose |
|-------|-------|---------|
| `management` | sirius, ansible-test-mgmt | Management network |
| `prod` | ansible-test-prod | Prod network |
| `seclab` | ansible-test-seclab | Security lab (no internet) |
| `k3s_server` | triangulum-alpha1, alpha2 | k3s control plane |
| `k3s_agent` | triangulum-beta1–4 | k3s workers |
| `k3s_db` | triangulum-db | PostgreSQL datastore |
| `k3s_lb` | triangulum-lb | Nginx API load balancer |

## Playbooks

| Playbook | Targets | What it does |
|----------|---------|-------------|
| `site.yml` | `all` | Applies devsec OS + SSH hardening and the `basehardening` role |
| `k3s-server.yml` | `k3s_server` | Opens k3s ports, installs k3s server with HA Postgres datastore |
| `k3s-agent.yml` | `k3s_agent` | Opens flannel/kubelet ports, installs k3s agent pointing at the LB |
| `k3s-db.yml` | `k3s_db` | Installs and configures PostgreSQL for k3s |
| `k3s-lb.yml` | `k3s_lb` | Installs Nginx with stream module, configures TCP load balancing for port 6443 |

## Roles

### `basehardening`

Lab-specific hardening that complements devsec. Configured via `group_vars/all.yml`.

- **firewalld** — enforces an allowlist of services (default: SSH only)
- **dnf-automatic** — enables automatic security updates
- **OpenSCAP** — installs `openscap-scanner` + `scap-security-guide` and runs a CIS Level 1 scan; report saved to `/var/log/openscap/report.html`

## Secrets

k3s playbooks pull secrets from Vault at runtime using `community.hashi_vault`:

```yaml
vault_k3s: "{{ lookup('community.hashi_vault.vault_kv2_get', 'k3s', mount_point='secret') }}"
```

`VAULT_ADDR` must be set (via `.envrc` + `direnv allow` in the repo root).

Expected keys in `secret/k3s`:
- `k3s_token` — shared cluster token
- `k3s_datastore_endpoint` — full Postgres connection string

## Usage

```bash
cd ansible/

# Install collections (first time)
ansible-galaxy collection install -r requirements.yml

# Harden all hosts
ansible-playbook playbooks/site.yml

# Stand up the k3s cluster (run in order)
ansible-playbook playbooks/k3s-db.yml
ansible-playbook playbooks/k3s-lb.yml
ansible-playbook playbooks/k3s-server.yml
ansible-playbook playbooks/k3s-agent.yml

# Target a specific host or group
ansible-playbook playbooks/site.yml --limit triangulum-alpha1
```
