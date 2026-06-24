# Sealed Secrets

## Overview

Bitnami **sealed-secrets** lets us store Kubernetes secrets in our **public** GitOps
repo safely. A `SealedSecret` custom resource holds *encrypted* data that is safe to
commit; an in-cluster controller (holding the private key) is the only thing that can
decrypt it back into a real `Secret`.

The controller runs as an ArgoCD app (`gitops/apps/sealed-secrets.yaml`) in the
`sealed-secrets` namespace, using a **bring-your-own** RSA-4096 key with rotation
disabled so the same key survives cluster rebuilds.

## Why it's needed

The repo is public, and a Kubernetes `Secret` is only base64-encoded. It's a prerequisite for cert-manager/step-ca, whose issuer credentials must be sealed rather than committed.

## Prerequisites

- A running cluster with ArgoCD and the root app-of-apps syncing `gitops/apps/`.
- `kubectl` access from the jumphost.
- The BYO private key available (in Bitwarden) for any rebuild.

## Steps (first-time setup)

### 1. Generate the BYO key


```bash
openssl req -x509 -nodes -newkey rsa:4096 -keyout tls.key -out tls.crt -days 3650 -subj "/CN=sealed-secret/O=sealed-secret"
```

Verify:
```bash
openssl rsa  -in tls.key -noout -check              # "RSA key ok"
openssl x509 -in tls.crt -noout -subject -enddate   # CN=sealed-secret, ~10y out
```

- `tls.key` → Bitwarden. 
- `tls.crt` → public cert.

### 2. Seed the key into the cluster before the controller starts

The controller adopts an existing labeled key on startup, so seed it first. NOTE: **This is the step repeated on every rebuild.**

```bash
kubectl create namespace sealed-secrets
kubectl -n sealed-secrets create secret tls sealed-secrets-key --cert=tls.crt --key=tls.key
kubectl -n sealed-secrets label secret sealed-secrets-key sealedsecrets.bitnami.com/sealed-secrets-key=active
kubectl -n sealed-secrets get secret sealed-secrets-key --show-labels
```

### 3. Install the controller as an ArgoCD app

`gitops/apps/sealed-secrets.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: sealed-secrets
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://bitnami.github.io/sealed-secrets
    chart: sealed-secrets
    targetRevision: 2.18.6
    helm:
      values: |
        fullnameOverride: sealed-secrets
        keyrenewperiod: "0"
  destination:
    server: https://kubernetes.default.svc
    namespace: sealed-secrets
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

Commit + push and the root app syncs it. Because the key was seeded in step 2, the controller adopts it. If the app was applied before seeding, run `kubectl -n sealed-secrets rollout restart deploy sealed-secrets` after seeding.

### 4. Install the `kubeseal` CLI (jumphost, AlmaLinux 9)

Not in distro repos — install the binary from the GitHub release. Match the controller
version (`kubectl -n sealed-secrets get deploy sealed-secrets -o jsonpath='{.spec.template.spec.containers[0].image}'`):

```bash
KUBESEAL_VERSION="0.30.0"   # set to the controller image tag
curl -fsSL -o kubeseal.tar.gz "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz"
tar -xzf kubeseal.tar.gz kubeseal
sudo install -m 0755 kubeseal /usr/local/bin/kubeseal
rm -f kubeseal kubeseal.tar.gz
kubeseal --version
```

Convenience alias (controller name/namespace are non-default):
```bash
alias kubeseal='kubeseal --controller-name sealed-secrets --controller-namespace sealed-secrets'
```

### 5. Verify the controller adopted BYO key

```bash
kubectl -n sealed-secrets get pods # Should be running
kubectl -n sealed-secrets get secrets -l sealedsecrets.bitnami.com/sealed-secrets-key # Should only be one key
kubeseal --controller-name sealed-secrets --controller-namespace sealed-secrets --fetch-cert
```

The fetched cert should match `tls.crt` with a ~10-year validity (the BYO tell; an auto-generated key has a ~30-day cert and a random-suffixed secret name).

## Seal workflow (day-to-day)

```bash
# 1. Template the secret (not applied)
kubectl create secret generic my-secret -n my-namespace \
  --from-literal=key=value --dry-run=client -o yaml > secret.yaml

# 2. Seal it (strict scope), write into gitops/apps
kubeseal --controller-name sealed-secrets --controller-namespace sealed-secrets \
  --scope strict --format=yaml < secret.yaml > gitops/apps/my-sealedsecret.yaml

# 3. Destroy the plaintext, sanity-check no cleartext leaked
rm secret.yaml
grep -i value gitops/apps/my-sealedsecret.yaml   # should return NOTHING

# 4. Commit + push; ArgoCD syncs and the controller unseals it into a real Secret
git add gitops/apps/my-sealedsecret.yaml && git commit -m "Add my-secret" && git push
```

## Verification

```bash
kubectl get sealedsecret,secret my-secret -n my-namespace   # both exist; SealedSecret SYNCED True
kubectl get secret my-secret -n my-namespace -o jsonpath='{.data.key}' | base64 -d; echo
```

## Disaster recovery / rebuild

The private key is not in the repo, so restore it manually from Bitwarden (or wherever)

1. Recreate the namespace and seed the key from Bitwarden — **step 2 above**.
2. Let ArgoCD install the controller (step 3); it adopts the restored key.
3. All committed `SealedSecret`s decrypt immediately (rotation off, key identical).

Backup command (capture the key any time):
```bash
kubectl get secret -n sealed-secrets -l sealedsecrets.bitnami.com/sealed-secrets-key -o yaml > main.key
# -> store in Bitwarden, then scrub locally:
shred -u main.key 2>/dev/null || rm -f main.key
```
