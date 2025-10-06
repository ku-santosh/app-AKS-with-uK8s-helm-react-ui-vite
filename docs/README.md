# React + TypeScript + Vite UI on AKS via Helm + GitLab CI/CD

This repository contains a production-ready Helm-based deployment for a React + TypeScript + Vite application, targeting AKS (uk8s) with Dev/UAT/Prod environments.

## Quick start
1. Configure GitLab CI Variables: ACR creds, KUBE_SERVER, KUBE_CA, KUBE_TOKEN (or per-env tokens)
2. Ensure helm is available in CI runners (image uses alpine/helm)
3. (Optional) Install cert-manager in the cluster and apply charts/react-ui/cluster-issuer.yaml for TLS
4. Merge to dev/uat/main to trigger pipeline (main requires manual approval)

## Helm usage
Dev:
  helm upgrade --install react-ui ./charts/react-ui -f charts/react-ui/values-dev.yaml -n at41457-dev-recsdiui-dev --create-namespace --atomic

UAT:
  helm upgrade --install react-ui ./charts/react-ui -f charts/react-ui/values-uat.yaml -n at41457-uat-recsdiui-uat --create-namespace --atomic

Prod:
  helm upgrade --install react-ui ./charts/react-ui -f charts/react-ui/values-prod.yaml -n at41457-prod-recsdiui-prod --create-namespace --atomic

## Notes
- Values files contain ingress TLS settings for production and optional TLS for UAT.
- Dev uses HTTP only for simplicity.
- Image tagging: CI pushes both a SHA tag and an env-latest tag.
