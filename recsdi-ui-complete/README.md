# 🚀 recsdi-ui

### Modern Web UI for RecsDI Platform  
Deployed and managed via Helm on Azure Kubernetes Service (AKS).  
Built automatically with GitLab CI/CD and deployed to multiple environments (Dev, UAT, and Prod).

---

## 📦 Project Overview

**recsdi-ui** is a frontend web application built using modern JS frameworks (React/Vite/TypeScript) and deployed through a fully automated GitLab CI/CD pipeline.

The pipeline builds Docker images, pushes them to Azure Container Registry (ACR), and deploys them via Helm to AKS clusters for:
- Development (`dev`)
- User Acceptance Testing (`uat`)
- Production (`prod`)

## 🚀 Highlights (What’s Inside)
| Feature                             | Description                                        |
| ----------------------------------- | -------------------------------------------------- |
| ✅ **5 Stages**                      | `test → build → validate → deploy → smoke_test`    |
| ✅ **Dynamic Environment Detection** | Automatically sets values, registry, and namespace |
| ✅ **Multi-Registry Support**        | Dev/UAT → `ubstdevacr`; Prod → `ubsreleaseacr`     |
| ✅ **Vault & Namespace Vars**        | Ready for secret integration                       |
| ✅ **Helm Lint & Dry-Run**           | Ensures no bad manifests before deploy             |
| ✅ **Atomic Helm Deploys**           | Auto rollback on failure                           |
| ✅ **Smoke Test Stage**              | Validates `/health` endpoint post-deployment       |
| ✅ **Tagged Builds**                 | Uses both SHA and `${ENV}-latest`                  |
| ✅ **Secure Credentials**            | No passwords in code — all from GitLab CI vars     |
| ✅ **Fully Documented**              | Each step explained for maintainers                |

## 🧩 Branch → Environment Map

| Branch | Namespace                    | Registry                   | Values File        | Environment |
| ------ | ---------------------------- | -------------------------- | ------------------ | ----------- |
| `dev`  | `at41457-dev-recsdiui-dev`   | `ubstdevacr.azurecr.io`    | `values-dev.yaml`  | Development |
| `uat`  | `at41457-uat-recsdiui-uat`   | `ubstdevacr.azurecr.io`    | `values-uat.yaml`  | UAT         |
| `main` | `at41457-prod-recsdiui-prod` | `ubsreleaseacr.azurecr.io` | `values-prod.yaml` | Production  |

## 🔐 Required GitLab Variables

| Variable                                                 | Description             | Scope   |
| -------------------------------------------------------- | ----------------------- | ------- |
| `AZURE_ACR_USERNAME`                                     | Dev ACR username        | Dev/UAT |
| `AZURE_ACR_PASSWORD`                                     | Dev ACR password        | Dev/UAT |
| `AZURE_ACR_USERNAME_PROD`                                | Prod ACR username       | Prod    |
| `AZURE_ACR_PASSWORD_PROD`                                | Prod ACR password       | Prod    |
| `KUBECONFIG`                                             | AKS cluster credentials | All     |
| `VAULT_AUTH_ROLE`, `VAULT_NAMESPACE`, `VAULT_SERVER_URL` | Vault config (optional) | All     |

## 🧠 Desired Promotion Flow

### You want your GitLab CI/CD to run on merge events, following this promotion chain:

| Merge Source → Target        | Purpose                         | Environment Deployed |
| ---------------------------- | ------------------------------- | -------------------- |
| **any feature branch → dev** | Developer merges feature to dev | **Deploy to Dev**    |
| **dev → uat**                | Promote tested build to UAT     | **Deploy to UAT**    |
| **uat → main**               | Promote approved release        | **Deploy to Prod**   |

### ✅ So instead of “run on branch name,” we will now:
- Detect merge target branch ($CI_MERGE_REQUEST_TARGET_BRANCH_NAME)
- Deploy based on merge request target, not commit branch
- Run pipeline only on merge request events
- Automatically build image once → reused downstream

## ✅ Summary — How It Works Now

| Merge Request     | Target Branch | Deploys To | Namespace                    | Registry                   |
| ----------------- | ------------- | ---------- | ---------------------------- | -------------------------- |
| `feature/* → dev` | dev           | Dev        | `at41457-dev-recsdiui-dev`   | `ubstdevacr.azurecr.io`    |
| `dev → uat`       | uat           | UAT        | `at41457-uat-recsdiui-uat`   | `ubstdevacr.azurecr.io`    |
| `uat → main`      | main          | Production | `at41457-prod-recsdiui-prod` | `ubsreleaseacr.azurecr.io` |

### 🧠 Key Improvements

✅ Runs only on merge requests
✅ Uses $CI_MERGE_REQUEST_TARGET_BRANCH_NAME instead of $CI_COMMIT_BRANCH
✅ Supports promotion chain: feature → dev → uat → main
✅ Avoids duplicate deployments
✅ Includes Helm lint, dry-run, and smoke test
✅ Safe rollback via --atomic