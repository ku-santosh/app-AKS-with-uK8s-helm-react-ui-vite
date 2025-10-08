# 🧱 CREATE POD GUIDE for RECSDI-UI (Helm + AKS)

This guide explains how to manually create, inspect, and manage Pods for the RECSDI-UI application.
Normally, Helm creates Pods automatically, but manual creation is helpful for testing or debugging.

---

## 🧩 1️⃣ What Is a Pod?
A Pod is the smallest deployable unit in Kubernetes — it runs one or more containers (for example, your Docker image of recsdi-ui).

Normally:

- Helm creates pods indirectly (via Deployments).
- But you can manually create and test pods for debugging or quick runs.

## ⚙️ 2️⃣ Create a Pod (Simple Example)
### 🔹 Option A: Create from Command Line (Quick test)
```bash
kubectl run test-pod --image=nginx --restart=Never --port=80
```
### ✅ This command:
Creates a Pod named test-pod
- Uses the nginx image
- Doesn’t use a Deployment (--restart=Never means just a single Pod)
- Exposes port 80 inside the pod

## ⚙️ 1️⃣ Create a Pod from CLI

```bash
kubectl run test-pod --image=nginx --restart=Never --port=80
kubectl get pods
kubectl describe pod test-pod
kubectl logs test-pod
kubectl exec -it test-pod -- sh
kubectl delete pod test-pod
```

---

## 📦 2️⃣ Create a Pod Using YAML File

### `recsdi-ui-pod.yaml`
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: recsdi-ui-pod
  namespace: at41457-dev-recsdiui-dev
  labels:
    app: recsdi-ui
spec:
  containers:
    - name: recsdi-ui
      image: ubsdevacr.azurecr.io/recsdi-ui:dev-latest
      ports:
        - containerPort: 80
      env:
        - name: VITE_ENV
          value: "development"
        - name: VITE_API_URL
          value: "https://dev-api.mycompany.com"
      resources:
        requests:
          cpu: 100m
          memory: 128Mi
        limits:
          cpu: 250m
          memory: 256Mi
```

### Apply:
```bash
kubectl apply -f recsdi-ui-pod.yaml
kubectl get pods -n at41457-dev-recsdiui-dev
kubectl describe pod recsdi-ui-pod -n at41457-dev-recsdiui-dev
```

---

## 🌐 3️⃣ Add Service to Access Pod

### `recsdi-ui-svc.yaml`
```yaml
apiVersion: v1
kind: Service
metadata:
  name: recsdi-ui-svc
  namespace: at41457-dev-recsdiui-dev
spec:
  selector:
    app: recsdi-ui
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: ClusterIP
```

Apply it:
```bash
kubectl apply -f recsdi-ui-svc.yaml
kubectl get svc -n at41457-dev-recsdiui-dev
kubectl port-forward svc/recsdi-ui-svc 8080:80 -n at41457-dev-recsdiui-dev
```
Then open: http://localhost:8080

---

## 🧠 4️⃣ Debug Pod (Ephemeral Shell)
```bash
kubectl run debug-shell -it --image=ubuntu --namespace at41457-dev-recsdiui-dev -- bash
curl http://recsdi-ui-svc
exit
kubectl delete pod debug-shell -n at41457-dev-recsdiui-dev
```

---

## 🧩 5️⃣ Helm-Managed Pods (Automatic)
Pods are created automatically by Helm when you deploy a chart:
```bash
helm upgrade --install recsdi-ui ./charts/recsdi-ui -f charts/recsdi-ui/values-dev.yaml -n at41457-dev-recsdiui-dev
kubectl get pods -n at41457-dev-recsdiui-dev
```

---

## ✅ 6️⃣ Common Commands

| Action | Command |
|--------|----------|
| Get all pods | `kubectl get pods -A` |
| Describe pod | `kubectl describe pod <name> -n <namespace>` |
| Logs | `kubectl logs <name> -n <namespace>` |
| Delete pod | `kubectl delete pod <name> -n <namespace>` |
| Restart | `kubectl rollout restart deployment <name> -n <namespace>` |
| YAML output | `kubectl get pod <name> -o yaml` |

---

# 💡 Tip:
#### If Helm creates pods automatically, manual pods should only be used for **debugging** or **testing image builds**.




### 📄 recsdi-ui/k8s/recsdi-ui-pod.yaml
```bash
# ===========================================================
# RECSDI-UI Single Pod Definition (Manual Deployment)
# -----------------------------------------------------------
# Use this file only for debugging or validating container image
# outside Helm chart or CI/CD flow.
# ===========================================================

apiVersion: v1
kind: Pod
metadata:
  name: recsdi-ui-pod
  namespace: at41457-dev-recsdiui-dev
  labels:
    app: recsdi-ui
    environment: dev
spec:
  containers:
    - name: recsdi-ui
      image: ubsdevacr.azurecr.io/recsdi-ui:dev-latest   # ← UBS Dev ACR image
      imagePullPolicy: Always
      ports:
        - containerPort: 80
      env:
        - name: VITE_ENV
          value: "development"
        - name: VITE_API_URL
          value: "https://dev-api.mycompany.com"
      resources:
        requests:
          cpu: 100m
          memory: 128Mi
        limits:
          cpu: 250m
          memory: 256Mi
      livenessProbe:
        httpGet:
          path: /
          port: 80
        initialDelaySeconds: 15
        periodSeconds: 20
      readinessProbe:
        httpGet:
          path: /
          port: 80
        initialDelaySeconds: 5
        periodSeconds: 10
  restartPolicy: Always
  imagePullSecrets:
    - name: acr-secret   # Optional: if UBS ACR credentials are used manually

```

## 🧩 Optional Service for Access

Add this next to it if you want to expose the Pod internally:

### 📄 recsdi-ui/k8s/recsdi-ui-svc.yaml
```bash
apiVersion: v1
kind: Service
metadata:
  name: recsdi-ui-svc
  namespace: at41457-dev-recsdiui-dev
spec:
  selector:
    app: recsdi-ui
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: ClusterIP
```

## 🧠 Usage Commands
```bash
# Apply pod and service
kubectl apply -f recsdi-ui/k8s/recsdi-ui-pod.yaml
kubectl apply -f recsdi-ui/k8s/recsdi-ui-svc.yaml

# Verify pod is running
kubectl get pods -n at41457-dev-recsdiui-dev

# Port forward for local access
kubectl port-forward svc/recsdi-ui-svc 8080:80 -n at41457-dev-recsdiui-dev

# Visit http://localhost:8080
```
### 🧾 Notes

- This does not replace Helm — it’s purely for quick testing or debugging container builds.
- Works well when you’re validating image pull from ubsdevacr.azurecr.io.
- Namespace must exist:

```bash
kubectl create namespace at41457-dev-recsdiui-dev
```
### Newly added files inside:
```bash
recsdi-ui/
└── k8s/
    ├── recsdi-ui-pod.yaml      # Manual pod deployment for testing/debug
    └── recsdi-ui-svc.yaml      # Internal ClusterIP service to expose the pod
```    
You can now manually create or test the RECSDI-UI container image in AKS using:
```bash
kubectl apply -f recsdi-ui/k8s/recsdi-ui-pod.yaml
kubectl apply -f recsdi-ui/k8s/recsdi-ui-svc.yaml
```
