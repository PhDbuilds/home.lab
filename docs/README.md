# home.lab docs

Operational docs and runbooks for my home lab

## What goes where

| Location | Purpose | Example |
|---|---|---|
| `docs/` (here) | **Operational runbooks** — procedures, workflows, disaster recovery, things that span components | "Seal a secret", "Rebuild the cluster" |
| `ansible/roles/*/README.md` | **Component reference** — what a role is and its variables, next to the code | `k8s-control-prep` README |
| `docs/postmortems/` | **Write-ups** — narrative of how something was built | `argocd-bootstrap.md` |

All Markdown, so GitHub renders them and a future **mkdocs** workload can serve them as-is

## Runbooks

- [Sealed Secrets](sealed-secrets.md) — seal/unseal workflow, key backup, rebuild restore.

## Runbook template

New operational docs should roughly follow this shape (keep it practical):

```markdown
# <Thing>

## Overview        — what this is, in 2-3 sentences
## Why it's needed — the problem it solves
## Prerequisites   — what must already exist
## Steps           — numbered, copy-pasteable commands
## Verification    — how to confirm it worked
## Disaster recovery / rebuild — how to restore it from scratch
```
