# k8s-control-prep

Bootstraps the control plane and installs cluster networking. Targets the `control` host group and runs **after** `k8s-node-prep`.

## What it does

- Renders `/etc/kubernetes/kubeadm-init.yaml` (CRI-O socket, control-plane endpoint, pod/service subnets, `systemd` cgroup driver)
- Runs `kubeadm init` with `--skip-phases=addon/kube-proxy` (Cilium replaces kube-proxy)
- Sets up a kubeconfig for the `core` user and fetches `admin.conf` back to the jumphost for local `kubectl`
- Installs **Helm** to `/usr/local/bin`
- Adds the Cilium Helm repo, renders values, and installs/upgrades **Cilium** (`kubeProxyReplacement: true`)
- Restarts CoreDNS so it picks up Cilium networking

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `control_plane_endpoint` | `k8sapi.home.lab` | DNS name for the API server |
| `control_plane_ip` | `10.0.0.20` | Control plane IP, used as Cilium's `k8sServiceHost` |
| `pod_subnet` | `10.244.0.0/16` | Pod CIDR |
| `service_subnet` | `10.96.0.0/12` | Service CIDR |
| `cilium_version` | `1.19.4` | Cilium chart version to install |

The playbook sets `KUBECONFIG=/etc/kubernetes/admin.conf` in its environment.

## Usage

```bash
ansible-playbook playbooks/k8s-control-prep.yml
```

Runs automatically as the second stage of `playbooks/k8s-init.yml`.
