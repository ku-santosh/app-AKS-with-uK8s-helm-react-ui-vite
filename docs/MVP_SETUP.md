# MVP Setup Checklist (Helm)

1. Create GitLab CI variables:
   - AZURE_ACR_USERNAME, AZURE_ACR_PASSWORD
   - KUBE_SERVER, KUBE_CA
   - KUBE_TOKEN (or per-env KUBE_TOKEN_DEV/UAT/PROD)
   - DEV_NAMESPACE, UAT_NAMESPACE, PROD_NAMESPACE

2. (Optional) Install cert-manager:
   kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
   kubectl apply -f charts/react-ui/cluster-issuer.yaml

3. Trigger pipeline by merging to dev/uat/main (main requires manual approval)
