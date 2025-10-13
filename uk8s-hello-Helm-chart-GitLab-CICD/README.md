# uk8s-hello Helm Chart + GitLab CI/CD

## Overview
This Helm chart deploys the `uk8s-hello` application with a Deployment, Service, and Istio VirtualService.

## Structure
- `Chart.yaml`: Chart metadata
- `values.yaml`: Configurable values
- `templates/`: Kubernetes manifests
- `.gitlab-ci.yml`: CI/CD pipeline for image build and deployment

## CI/CD Flow
- Merging to **dev**, **uat**, or **main** triggers automatic build and deployment.
- Uses `$CI_COMMIT_SHORT_SHA` as image tag.
- Helm deploys to namespaces `et14157-dev-recsdiui-dev`, `et14157-uat-recsdiui-uat`, and `et14157-prod-recsdiui-prod`.

## Deploy manually
```bash
helm upgrade --install uk8s-hello ./uk8s-hello-helm --namespace et14157-dev-recsdiui-dev
```
