# 🧭 Complete Global Helm Command Reference (2025 Edition)

This document contains all global and production-usable Helm commands for development, deployment, debugging, rollback, and maintenance across AKS (uk8s), EKS, GKE, and on-prem Kubernetes.

---

## 🧩 1️⃣ Global Setup & Environment Commands

| Command | Description | Example |
|----------|--------------|----------|
| `helm version` | Show Helm version and verify installation | `helm version --short` |
| `helm env` | Show Helm’s environment variables | `helm env` |
| `helm plugin list` | List installed Helm plugins | `helm plugin list` |
| `helm plugin install <url>` | Install plugin from Git | `helm plugin install https://github.com/databus23/helm-diff` |
| `helm completion bash` | Generate bash completion script | `helm completion bash > /etc/bash_completion.d/helm` |
| `helm completion zsh` | Generate zsh completion script | `helm completion zsh > ~/.oh-my-zsh/completions/_helm` |

💡 *Tip:* Use plugins like `helm-diff`, `helm-secrets`, and `helm-unittest` for enterprise workflows.

---

## ⚙️ 2️⃣ Repository Management

| Command | Description | Example |
|----------|--------------|----------|
| `helm repo list` | List all Helm repos | `helm repo list` |
| `helm repo add <name> <url>` | Add new repo | `helm repo add bitnami https://charts.bitnami.com/bitnami` |
| `helm repo remove <name>` | Remove a repo | `helm repo remove bitnami` |
| `helm repo update` | Refresh repo index | `helm repo update` |
| `helm search repo <keyword>` | Search charts in local repos | `helm search repo nginx` |
| `helm search hub <keyword>` | Search charts on ArtifactHub | `helm search hub wordpress` |

---

## 🧱 3️⃣ Chart Development & Packaging

| Command | Description | Example |
|----------|--------------|----------|
| `helm create <name>` | Scaffold a new chart | `helm create react-ui` |
| `helm lint <chart>` | Validate chart syntax | `helm lint ./charts/react-ui` |
| `helm template <chart>` | Render YAML without deploying | `helm template ./charts/react-ui -f values-prod.yaml` |
| `helm dependency update` | Update subchart dependencies | `helm dependency update ./charts/react-ui` |
| `helm dependency build` | Build chart dependencies | `helm dependency build ./charts/react-ui` |
| `helm package <chart>` | Package chart into .tgz | `helm package ./charts/react-ui` |
| `helm show values <chart>` | Display default values | `helm show values ./charts/react-ui` |
| `helm show all <chart>` | Show all chart data | `helm show all ./charts/react-ui` |

---

## 🚀 4️⃣ Install, Upgrade, Rollback

| Command | Description | Example |
|----------|--------------|----------|
| `helm install <release> <chart>` | Install new release | `helm install react-ui ./charts/react-ui -n dev` |
| `helm upgrade <release> <chart>` | Upgrade release | `helm upgrade react-ui ./charts/react-ui -f values-prod.yaml -n prod` |
| `helm upgrade --install` | Install if missing, else upgrade | `helm upgrade --install react-ui ./charts/react-ui -f values-uat.yaml -n uat --atomic` |
| `helm uninstall <release>` | Delete release | `helm uninstall react-ui -n dev` |
| `helm rollback <release> <revision>` | Roll back to a previous version | `helm rollback react-ui 2 -n prod` |
| `helm history <release>` | View revision history | `helm history react-ui -n prod` |
| `helm status <release>` | Show release status | `helm status react-ui -n prod` |
| `helm get values <release>` | Get applied values | `helm get values react-ui -n uat` |
| `helm get manifest <release>` | Show rendered manifests | `helm get manifest react-ui -n prod` |
| `helm get all <release>` | Get all release info | `helm get all react-ui -n dev` |

💡 *Tip:* Always use `--atomic` for safe rollback on failure.

---

## 🧾 5️⃣ Value Overrides

| Command | Description | Example |
|----------|--------------|----------|
| `--set key=value` | Override a value | `helm upgrade react-ui ./charts/react-ui --set image.tag=prod-1234` |
| `--set-string key=value` | Force string override | `helm upgrade react-ui ./charts/react-ui --set-string replicaCount="3"` |
| `--set-file key=path` | Use value from file | `helm upgrade react-ui ./charts/react-ui --set-file secrets.token=token.txt` |
| `-f file.yaml` | Load values from file | `helm upgrade react-ui ./charts/react-ui -f values-prod.yaml` |
| `-f file1.yaml -f file2.yaml` | Merge multiple files | `helm upgrade react-ui ./charts/react-ui -f base.yaml -f prod.yaml` |

---

## 🧰 6️⃣ Debugging & Troubleshooting

| Command | Description | Example |
|----------|--------------|----------|
| `helm template --debug` | Render and debug | `helm template ./charts/react-ui --debug` |
| `helm install --dry-run --debug` | Simulate deployment | `helm install react-ui ./charts/react-ui --dry-run --debug` |
| `helm get all <release>` | Show all manifests and values | `helm get all react-ui -n prod` |
| `helm diff upgrade ...` | Compare deployed vs local | `helm diff upgrade react-ui ./charts/react-ui -f values-prod.yaml` |
| `helm test <release>` | Run post-install tests | `helm test react-ui -n uat` |

---

## 🔐 7️⃣ Security, Signing & OCI Registry

| Command | Description | Example |
|----------|--------------|----------|
| `helm sign <chart.tgz>` | Sign chart with GPG | `helm sign react-ui-2.1.0.tgz --key devops@mycompany.com` |
| `helm verify <chart.tgz>` | Verify signed chart | `helm verify react-ui-2.1.0.tgz` |
| `helm registry login <registry>` | Login to OCI registry | `helm registry login myregistry.azurecr.io` |
| `helm push <chart.tgz>` | Push chart to OCI repo | `helm push react-ui-2.1.0.tgz oci://myregistry.azurecr.io/helm` |
| `helm pull <chart>` | Pull chart from repo | `helm pull oci://myregistry.azurecr.io/helm/react-ui --version 2.1.0` |

---

## 🌐 8️⃣ Cert-Manager & TLS

| Command | Description | Example |
|----------|--------------|----------|
| `kubectl get clusterissuer` | List ClusterIssuers | `kubectl get clusterissuer` |
| `kubectl describe clusterissuer letsencrypt-prod` | Inspect cert issuer | `kubectl describe clusterissuer letsencrypt-prod` |
| `kubectl get certificate -A` | List issued certs | `kubectl get certificate -A` |
| `kubectl describe certificate <name>` | Inspect certificate | `kubectl describe certificate reactui-prod-tls -n prod` |

---

## 🧹 9️⃣ Cleanup & Maintenance

| Command | Description | Example |
|----------|--------------|----------|
| `helm uninstall <release>` | Remove Helm release | `helm uninstall react-ui -n dev` |
| `helm uninstall --keep-history` | Keep history | `helm uninstall react-ui -n uat --keep-history` |
| `helm uninstall --no-hooks` | Skip hooks on uninstall | `helm uninstall react-ui -n prod --no-hooks` |
| `helm delete --purge` | (Deprecated) full remove | `helm delete --purge react-ui` |

---

## 🧠 🔟 Global Cluster Context

| Command | Description | Example |
|----------|--------------|----------|
| `helm list -A` | List all releases in all namespaces | `helm list -A` |
| `helm get all <release>` | Get complete info | `helm get all react-ui -n prod` |
| `helm show all <chart>` | Print chart info | `helm show all ./charts/react-ui` |
| `helm show readme <chart>` | Display chart README | `helm show readme ./charts/react-ui` |
| `helm status --show-resources` | Show resources | `helm status react-ui -n prod --show-resources` |

---

## 🧾 Optional Plugins

| Plugin | Purpose | Install |
|--------|----------|----------|
| **helm-diff** | Compare manifests before upgrade | `helm plugin install https://github.com/databus23/helm-diff` |
| **helm-secrets** | Manage encrypted secrets | `helm plugin install https://github.com/jkroepke/helm-secrets` |
| **helm-unittest** | Unit test Helm charts | `helm plugin install https://github.com/quintush/helm-unittest` |
| **helm-schema-gen** | Generate JSON schemas | `helm plugin install https://github.com/karuppiah7890/helm-schema-gen` |

---

## 🧱 Recommended Workflow (Per Environment)

| Environment |	Command | Description
|--------|----------|----------|
| **Dev** |	`helm upgrade --install react-ui ./charts/react-ui -f charts/react-ui/values-dev.yaml -n dev --atomic` |	Quick deploy with no TLS |
| **UAT** |	`helm upgrade --install react-ui ./charts/react-ui -f charts/react-ui/values-uat.yaml -n uat --atomic` |	Test HTTPS with staging cert |
| **Prod** |	`helm upgrade --install react-ui ./charts/react-ui -f charts/react-ui/values-prod.yaml -n prod --atomic` |	Full TLS-enabled deploy |
| **Rollback (any)** |	`helm rollback react-ui 1 -n prod` |	Roll back to a previous revision safely |

---

✅ **Summary:**  
This file now includes **all global Helm commands** you’ll ever need — from cluster management to CI/CD automation, testing, TLS, signing, and rollback.

