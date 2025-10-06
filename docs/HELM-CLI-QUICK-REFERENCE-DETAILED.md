# 🧾 HELM CLI QUICK REFERENCE (Detailed)

## 🧠 Setup
- `helm version` → Check your Helm installation.
- `helm repo add bitnami https://charts.bitnami.com/bitnami` → Add repo.
- `helm repo update` → Refresh repository index.
- `kubectl config use-context aks-uk8s` → Switch kube context to AKS.

## 🚀 Deploy / Upgrade
- **Dev:**  
  `helm upgrade --install react-ui ./charts/react-ui -f charts/react-ui/values-dev.yaml -n dev --atomic`  
  → Deploys React UI to Dev (non-TLS).

- **UAT:**  
  `helm upgrade --install react-ui ./charts/react-ui -f charts/react-ui/values-uat.yaml -n uat --atomic`  
  → Deploys to UAT with optional staging TLS.

- **Prod:**  
  `helm upgrade --install react-ui ./charts/react-ui -f charts/react-ui/values-prod.yaml -n prod --atomic`  
  → Deploys to production with cert-manager TLS and HTTPS enforced.

⚠️ *Tip:* Always use `--atomic` to ensure rollback on failed deployments.

## 🔍 Debugging
- `helm list -A` → List all Helm releases across namespaces.  
- `helm status react-ui -n prod` → View current release info.  
- `helm get all react-ui -n prod` → Display manifests and values.  
- `kubectl get pods -n prod` → View pods.  
- `kubectl logs <pod> -n prod` → Check container logs.

💡 *Tip:* Combine `helm diff upgrade ...` for preview before upgrading.

## 🔄 Rollback / Uninstall
- `helm history react-ui -n prod` → Show deployment history.
- `helm rollback react-ui 1 -n prod` → Roll back to revision 1.
- `helm uninstall react-ui -n prod` → Delete release & resources.

## 🔐 TLS / Cert-Manager
- `kubectl get clusterissuer` → Verify cert-manager issuer.
- `kubectl get certificate -A` → List issued certs.
- `kubectl describe certificate reactui-prod-tls -n prod` → Inspect cert details.

⚠️ *If certificate not issued:*  
Check cert-manager pod logs and ensure ClusterIssuer name matches `letsencrypt-prod`.

## 🧰 Common Aliases
```
alias hl='helm list -A'               # List all releases
alias hi='helm install'               # Install chart
alias hu='helm upgrade --install'     # Upgrade or install
alias hr='helm rollback'              # Roll back
alias hs='helm status'                # Show status
alias hdel='helm uninstall'           # Delete release
```

✅ **Recommended Flow (Prod):**
```
helm lint ./charts/react-ui
helm upgrade --install react-ui ./charts/react-ui -f charts/react-ui/values-prod.yaml -n prod --atomic
helm status react-ui -n prod --show-resources
```
