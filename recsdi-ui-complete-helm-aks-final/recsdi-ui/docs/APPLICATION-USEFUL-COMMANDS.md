# 🧰 USEFUL COMMANDS for RECSDI-UI (Helm + AKS + GitLab CI/CD)

This document contains **essential commands** to deploy, monitor, debug, and manage the RECSDI-UI application across Dev, UAT, and Prod environments.

---

## 🧱 1️⃣ Cluster & Context Setup (Azure CLI + AKS)
```bash
az login
az account set --subscription "uk8s-at53357-neu-dev"
az aks get-credentials --resource-group AT53357_DEV_NEU_AKS --name kd416753357neu01 --overwrite-existing
kubectl config current-context
kubectl get nodes -o wide
```

---

## ⚙️ 2️⃣ Namespace Creation
```bash
kubectl create namespace at41457-dev-recsdiui-dev
kubectl create namespace at41457-uat-recsdiui-uat
kubectl create namespace at41457-prod-recsdiui-prod
```

---

## 📦 3️⃣ ACR Integration (One-Time)
```bash
az aks update -n kd416753357neu01 -g AT53357_DEV_NEU_AKS --attach-acr ubsdevacr
az aks update -n kd416753357neu01 -g AT53357_DEV_NEU_AKS --attach-acr ubsreleaseacr
```

---

## 🚀 4️⃣ Deploy Using Helm

### 🧩 Dry Run
```bash
helm install recsdi-ui ./charts/recsdi-ui -f charts/recsdi-ui/values-dev.yaml --namespace at41457-dev-recsdiui-dev --dry-run --debug
```
---

```bash
helm lint ./charts/recsdi-ui
helm upgrade --install recsdi-ui ./charts/recsdi-ui -f charts/recsdi-ui/values-dev.yaml -n at41457-dev-recsdiui-dev
```

### ✅ Deploy (DEV/UAT/PROD)
```bash
helm upgrade --install recsdi-ui ./charts/recsdi-ui -f charts/recsdi-ui/values-dev.yaml --namespace at41457-dev-recsdiui-dev --create-namespace --atomic

helm upgrade --install recsdi-ui ./charts/recsdi-ui -f charts/recsdi-ui/values-uat.yaml --namespace at41457-uat-recsdiui-uat --create-namespace --atomic

helm upgrade --install recsdi-ui ./charts/recsdi-ui -f charts/recsdi-ui/values-prod.yaml --namespace at41457-prod-recsdiui-prod --create-namespace --atomic
```

---

## 🔍 5️⃣ Check Helm Releases
```bash
helm list -A
helm status recsdi-ui -n at41457-dev-recsdiui-dev
helm diff upgrade recsdi-ui ./charts/recsdi-ui -f charts/recsdi-ui/values-dev.yaml -n at41457-dev-recsdiui-dev
```
## 🧱 Recommended Workflow (Per Environment)

| Environment |	Command | Description
|--------|----------|----------|
| **Dev** |	`helm upgrade --install recsdi-ui ./charts/recsdi-ui -f charts/recsdi-ui/values-dev.yaml -n dev --atomic` |	Quick deploy with no TLS |
| **UAT** |	`helm upgrade --install recsdi-ui ./charts/recsdi-ui -f charts/recsdi-ui/values-uat.yaml -n uat --atomic` |	Test HTTPS with staging cert |
| **Prod** |	`helm upgrade --install recsdi-ui ./charts/recsdi-ui -f charts/recsdi-ui/values-prod.yaml -n prod --atomic` |	Full TLS-enabled deploy |
| **Rollback (any)** |	`helm rollback recsdi-ui 1 -n prod` |	Roll back to a previous revision safely |

---
# kubectl & helm Cheat Sheet
```bash
Helm:
  helm lint ./charts/recsdi-ui
  helm upgrade --install recsdi-ui ./charts/recsdi-ui -f charts/recsdi-ui/values-prod.yaml -n <namespace> --atomic
  helm list -n <namespace>
  helm rollback recsdi-ui <revision> -n <namespace>
  helm uninstall recsdi-ui -n <namespace>
```
```bash
kubectl:
  kubectl get pods -n <ns>
  kubectl logs <pod> -n <ns>
  kubectl exec -it <pod> -n <ns> -- sh
  kubectl apply -f charts/recsdi-ui/cluster-issuer.yaml
```
---
## 🚀 Deploy / Upgrade
- **Dev:**  
  `helm upgrade --install recsdi-ui ./charts/recsdi-ui -f charts/recsdi-ui/values-dev.yaml -n dev --atomic`  
  → Deploys React UI to Dev (non-TLS).

- **UAT:**  
  `helm upgrade --install recsdi-ui ./charts/recsdi-ui -f charts/recsdi-ui/values-uat.yaml -n uat --atomic`  
  → Deploys to UAT with optional staging TLS.

- **Prod:**  
  `helm upgrade --install recsdi-ui ./charts/recsdi-ui -f charts/recsdi-ui/values-prod.yaml -n prod --atomic`  
  → Deploys to production with cert-manager TLS and HTTPS enforced.

⚠️ *Tip:* Always use `--atomic` to ensure rollback on failed deployments.
---

## 🧠 6️⃣ Pod & Service Monitoring
```bash
kubectl get all -n at41457-dev-recsdiui-dev
kubectl get pods -n at41457-dev-recsdiui-dev
kubectl describe pod <pod-name> -n at41457-dev-recsdiui-dev
kubectl logs <pod-name> -n at41457-dev-recsdiui-dev
kubectl logs -f <pod-name> -n at41457-dev-recsdiui-dev
kubectl exec -it <pod-name> -n at41457-dev-recsdiui-dev -- sh
```

---

## 🧪 7️⃣ Networking Tests
```bash
kubectl port-forward svc/recsdi-ui 8080:80 -n at41457-dev-recsdiui-dev
kubectl get svc recsdi-ui -n at41457-dev-recsdiui-dev -o wide
kubectl get ingress -n at41457-dev-recsdiui-dev
```

---

## 🔧 8️⃣ Rollback & Cleanup
```bash
helm rollback recsdi-ui 1 -n at41457-dev-recsdiui-dev
helm uninstall recsdi-ui -n at41457-dev-recsdiui-dev
kubectl delete namespace at41457-dev-recsdiui-dev
```

---

## 🧰 9️⃣ TLS & Ingress Validation
```bash
kubectl get pods -n cert-manager
kubectl get clusterissuer
kubectl describe certificate -n at41457-dev-recsdiui-dev
kubectl describe ingress recsdi-ui -n at41457-dev-recsdiui-dev
```

---

## 🔄 10️⃣ Manual CI/CD Image Push
```bash
docker login ubsdevacr.azurecr.io -u $ACR_USERNAME_DEV -p $ACR_PASSWORD_DEV
docker build -t ubsdevacr.azurecr.io/recsdi-ui:manual-test .
docker push ubsdevacr.azurecr.io/recsdi-ui:manual-test
helm upgrade --install recsdi-ui ./charts/recsdi-ui -f charts/recsdi-ui/values-dev.yaml --set image.tag=manual-test --namespace at41457-dev-recsdiui-dev
```

---

## 🧩 11️⃣ Cluster Debug & Resource Checks
```bash
kubectl get nodes -o wide
kubectl top pods -n at41457-dev-recsdiui-dev
kubectl top nodes
kubectl rollout restart deployment recsdi-ui -n at41457-dev-recsdiui-dev
kubectl get events -n at41457-dev-recsdiui-dev --sort-by=.metadata.creationTimestamp
```

---

## ✅ 12️⃣ Quick Reference
| Purpose | Command |
|----------|----------|
| Helm Version | `helm version` |
| K8s Version | `kubectl version --short` |
| Validate Chart | `helm lint ./charts/recsdi-ui` |
| Render Manifests | `helm template recsdi-ui ./charts/recsdi-ui -f charts/recsdi-ui/values-dev.yaml` |
| Get App URL | `kubectl get ingress recsdi-ui -n at41457-dev-recsdiui-dev` |

---

### 💡 Tip:
> Always test deployments with `helm lint` and `--dry-run` before applying to ensure YAML correctness.
