# 🧩 HELM CLI QUICK REFERENCE (Minimal)

### 🧠 Setup
helm version                              # Check Helm version
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update                          # Update repo index
kubectl config use-context aks-uk8s       # Switch to AKS cluster

### 🚀 Deploy / Upgrade
helm upgrade --install react-ui ./charts/react-ui -f charts/react-ui/values-dev.yaml -n dev --atomic
helm upgrade --install react-ui ./charts/react-ui -f charts/react-ui/values-uat.yaml -n uat --atomic
helm upgrade --install react-ui ./charts/react-ui -f charts/react-ui/values-prod.yaml -n prod --atomic

### 🔍 Debugging
helm list -A                              # List all Helm releases
helm status react-ui -n prod              # View release status
helm get all react-ui -n prod             # Get all manifests & values
kubectl get pods -n prod                  # Check pod status
kubectl logs <pod> -n prod                # Check logs

### 🔄 Rollback / Uninstall
helm history react-ui -n prod             # Check revision history
helm rollback react-ui 1 -n prod          # Rollback to previous version
helm uninstall react-ui -n prod           # Remove Helm release

### 🔐 TLS / Cert-Manager
kubectl get clusterissuer                 # Verify ClusterIssuer
kubectl get certificate -A                # List TLS certificates
kubectl describe certificate reactui-prod-tls -n prod

### 🧰 Common Aliases
alias hl='helm list -A'
alias hu='helm upgrade --install --atomic'
alias hr='helm rollback'
alias hs='helm status'
alias hdel='helm uninstall'
