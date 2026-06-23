# k8s-node-prep

Common preparation applied to **every** Kubernetes node (control plane and workers) before `kubeadm` runs. Targets the `k8s` host group, which is made up of Fedora CoreOS machines.

## What it does

- Sets the hostname to the inventory name
- Masks `zincati.service` so FCOS doesn't auto-update the cluster out from under you
- Loads and persists the `overlay` and `br_netfilter` kernel modules
- Writes the Kubernetes networking sysctls (bridge netfilter + IP forwarding)
- Adds the `pkgs.k8s.io` package repo and layers **CRI-O**, `kubelet`, `kubeadm`, and `kubectl` via `rpm-ostree`
- Reboots into the new `rpm-ostree` deployment **only** if one is staged but not yet booted
- Enables/starts CRI-O and enables `kubelet` (which idles until `kubeadm` configures it)
- Adds the control-plane endpoint to `/etc/hosts`
- Removes CRI-O's default bridge CNI configs so Cilium is the only CNI

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `k8s_version` | `1.35` | Kubernetes minor version for the package repo |
| `control_plane_ip` | `10.0.0.20` | IP of the control plane, written to `/etc/hosts` |
| `control_plane_endpoint` | `k8sapi.home.lab` | DNS name for the API server |

## Usage

```bash
ansible-playbook playbooks/k8s-node-prep.yml
```

Runs automatically as the first stage of `playbooks/k8s-init.yml`.
