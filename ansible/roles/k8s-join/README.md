# k8s-join

Joins worker nodes to the cluster. Targets the `workers` host group and runs **after** the control plane is up.

## What it does

- Generates a fresh join command on the control node with `kubeadm token create --print-join-command` (delegated, run once)
- Runs the join on each worker with the CRI-O socket, guarded by `creates: /etc/kubernetes/kubelet.conf` so it's idempotent

## Usage

```bash
ansible-playbook playbooks/k8s-join.yml
```

Runs automatically as the final stage of `playbooks/k8s-init.yml`.
