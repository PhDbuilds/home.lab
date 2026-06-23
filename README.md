# Proxmox Home Lab — Infrastructure as Code

Fully (almost) automated homelab built on Proxmox using IaC stack

```
Terraform  →  clones that image and provisions all VMs
Ansible  →  configures and hardens everything post-boot
Packer/Kickstart → builds and provisions golden image
```

Secrets for all tools are stored in direnv/.envrc.

- [`terraform/`](terraform/) — VM provisioning
- [`ansible/`](ansible/) — Post-boot configuration and hardening
- [`packer/`](packer/) — Builds AlmaLinux 9 minimal template

---

## Naming Theme

VMs use a space-themed naming scheme. Mostly..

## VM Inventory

| Host | VM ID | Role | Network | IP |
|------|-------|------|---------|----|
| polaris | 100 | Firewall / router (OPNsense) | All bridges | — |
| sirius | 101 | Jumphost | MGMT | 10.0.0.7 |
| vega | 102 | Grafana | MGMT | 10.0.0.3 |
| hubble | 105 | Ollama | MGMT | 10.0.0.60 |
| pihole | 401 | pihole | MGMT | 10.0.0.53 |
| triangulum-alpha | 500 | k8s control plane | MGMT | 10.0.0.20 |
| triangulum-beta | 501 | k8s worker | MGMT | 10.0.0.21 |
| triangulum-gamma | 502 | k8s worker | MGMT | 10.0.0.22 |
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

## Kubernetes

A `kubeadm`-bootstrapped cluster running on **Fedora CoreOS** (PXE-provisioned via pulsar), named under the `triangulum` theme. One control plane and two workers, all on the Management network (for now).

| Component | Choice |
|-----------|--------|
| OS | Fedora CoreOS (immutable, `rpm-ostree`-layered) |
| Container runtime | CRI-O |
| Bootstrap | `kubeadm` (k8s v1.35) |
| CNI | Cilium v1.19.4 (kube-proxy replacement) |
| API endpoint | `k8sapi.home.lab` → 10.0.0.20:6443 |
| Pod / Service subnet | `10.244.0.0/16` / `10.96.0.0/12` |

The cluster is provisioned from the `terraform/modules/fcos-k8s` module and configured by the Ansible roles documented in [`ansible/roles/k8s-node-prep`](ansible/roles/k8s-node-prep/) and [`ansible/roles/k8s-control-prep`](ansible/roles/k8s-control-prep/).

```bash
cd ansible/

# Full cluster bring-up: prep all nodes, init control plane, join workers
ansible-playbook playbooks/k8s-init.yml
```

`k8s-init.yml` chains the three stages, which can also be run individually:

| Playbook | What it does |
|----------|--------------|
| `k8s-node-prep.yml` | Common prep for every node (CRI-O, kube tooling, sysctls, kernel modules) |
| `k8s-control-prep.yml` | `kubeadm init` on the control plane, installs Cilium + Helm |
| `k8s-join.yml` | Joins workers using a freshly minted `kubeadm` token |

The control plane's `admin.conf` is fetched back to the jumphost (sirius) for local `kubectl` use.

## Prerequisites

- Terraform >= 1.14.0
- Ansible >= 2.15
- Packer >= 1.2.2
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
