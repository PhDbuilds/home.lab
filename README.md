# Proxmox Home Lab — Infrastructure as Code

Fully (almost) automated homelab built on Proxmox using an IaC stack

```
Packer/Kickstart → builds and provisions the golden AlmaLinux image
Terraform        → clones that image and provisions all VMs
Ansible          → configures and hardens everything post-boot
Argo CD          → syncs everything running inside the cluster (GitOps)
```

Secrets for all tools are stored in direnv/.envrc.

- [`packer/`](packer/) — Builds the AlmaLinux 9 minimal template
- [`terraform/`](terraform/) — VM provisioning
- [`ansible/`](ansible/) — Post-boot configuration and hardening
- [`gitops/`](gitops/) — Argo CD app-of-apps: everything running in k3s
- [`docs/`](docs/) — Operational runbooks

---

## Naming Theme

VMs use a space-themed naming scheme. Mostly..

## VM Inventory

| Host | VM ID | Role | Network | IP |
|------|-------|------|---------|----|
| polaris | 100 | Firewall / router (OPNsense) | All bridges | — |
| sirius | 101 | Jumphost + internal ACME CA (step-ca) | MGMT | 10.0.0.7 |
| hubble | 105 | Ollama (behind Caddy w/ ACME cert) | MGMT | 10.0.0.60 |
| pihole | 401 | Pi-hole DNS | MGMT | 10.0.0.53 |
| triangulum-alpha | 500 | k3s server | MGMT | 10.0.0.20 |
| triangulum-beta | 501 | k3s agent | MGMT | 10.0.0.21 |
| pulsar | 900 | PXE server | MGMT | 10.0.0.8 |

## Network Layout

All networking is virtual inside Proxmox using Open vSwitch bridges. OPNsense (polaris) acts as the sole router and firewall between all segments.

| Bridge | Network | Subnet | OPNsense Gateway | Policy |
|--------|---------|--------|-------------------|--------|
| vmbr0 | LAN | 192.168.1.0/24 | 192.168.1.2 | Uplink to home router |
| vmbr1 | Management | 10.0.0.0/24 | 10.0.0.1 | Full access everywhere |
| vmbr2 | Prod | 10.10.0.0/24 | 10.10.0.1 | Internet only, no cross-network |
| vmbr3 | Test | 10.20.0.0/24 | 10.20.0.1 | Test network |
| vmbr4 | SecLab | 10.30.0.0/24 | - | Airgapped network |

## Base Config

Every host gets a common baseline applied from the jumphost:

```bash
cd ansible/
ansible-playbook playbooks/site.yml
```

| Role | What it does |
|------|--------------|
| `basehardening` | Common hardening across all hosts |
| `pihole_dns` | Points every host at Pi-hole for `home.lab` resolution |
| `step_ca` | Stands up the internal Smallstep CA on sirius (ACME at `sirius.home.lab:8443`) |

Hubble runs Ollama behind Caddy, which pulls its cert from step-ca over ACME (`playbooks/hubble.yml`).

## Kubernetes

A **k3s** cluster running on **Fedora CoreOS** (PXE-provisioned via pulsar), named under the `triangulum` theme. One server and one agent, both on the Management network (for now).

| Component | Choice |
|-----------|--------|
| OS | Fedora CoreOS (immutable, `rpm-ostree`-layered) |
| Distribution | k3s (`stable` channel, SELinux enabled) |
| Container runtime | containerd (bundled with k3s) |
| CNI | Flannel (VXLAN, k3s default) |
| Ingress | Traefik (k3s default) |
| GitOps | Argo CD (app-of-apps) |
| API endpoint | `k8sapi.home.lab` → 10.0.0.20:6443 |
| Pod / Service subnet | `10.42.0.0/16` / `10.43.0.0/16` (k3s defaults) |

The nodes are provisioned from the `terraform/modules/fcos-k8s` module and configured by the Ansible roles [`k3s_common`](ansible/roles/k3s_common/), [`k3s_server`](ansible/roles/k3s_server/), and [`k3s_agent`](ansible/roles/k3s_agent/).

```bash
cd ansible/

# Full cluster bring-up: prep nodes, install the server, join the agent
ansible-playbook playbooks/k3s.yml
```

`k3s.yml` runs the three stages in order:

| Role | What it does |
|------|--------------|
| `k3s_common` | Common prep for every node (kernel modules, sysctls, k3s-selinux policy) |
| `k3s_server` | Installs the k3s server, Helm, and fetches the kubeconfig |
| `k3s_agent` | Joins the agent using the server's node-token |

The server's kubeconfig is fetched back to the jumphost (sirius) and repointed at `k8sapi.home.lab` for local `kubectl` use.

## GitOps (Argo CD)

Everything running inside the cluster is managed by Argo CD using the app-of-apps pattern. Argo CD is bootstrapped once with Ansible, then manages itself and everything else from this repo:

```bash
cd ansible/

# Install Argo CD via Helm and apply the root app-of-apps
ansible-playbook playbooks/k3s-argocd.yml
```

The root app ([`gitops/bootstrap/root-app.yaml`](gitops/bootstrap/root-app.yaml)) points at two directories, and Argo CD auto-syncs (prune + self-heal) from there:

| Path | Contents |
|------|----------|
| [`gitops/apps/platform/`](gitops/apps/platform/) | cert-manager, sealed-secrets, cloudnative-pg, reloader, kube-prometheus-stack, cluster-config |
| [`gitops/apps/applications/`](gitops/apps/applications/) | homepage, miniflux, uptime-kuma |

Secrets are committed encrypted with [Sealed Secrets](docs/sealed-secrets.md); cert-manager issues TLS from the step-ca `ClusterIssuer`.

## Services

Everything is reachable at `*.home.lab` (resolved via Pi-hole):

| Service | URL | Notes |
|---------|-----|-------|
| Proxmox VE | https://192.168.1.180:8006/ | Hypervisor |
| OPNsense | https://10.0.0.1/ | Firewall |
| Pi-hole | http://pihole.home.lab/admin | DNS sinkhole |
| Argo CD | https://argocd.home.lab/ | GitOps |
| Grafana | https://grafana.home.lab/ | Infra monitoring |
| Prometheus | https://prometheus.home.lab/ | Metrics |
| Uptime Kuma | https://uptime-kuma.home.lab/ | Uptime monitoring |
| Miniflux | https://miniflux.home.lab/ | RSS reader |
| Homepage | https://homepage.home.lab/ | Dashboard |

## Prerequisites

- Terraform >= 1.14.7 (`bpg/proxmox` provider)
- Ansible >= 2.15
- Packer >= 1.2.2
- `direnv` (`sudo dnf install direnv`)

## Setup

**1. Hook direnv into zsh** (one-time):

```bash
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
source ~/.zshrc
```

**2. Allow direnv** (each time a change is made to .envrc):

```bash
direnv allow
```
