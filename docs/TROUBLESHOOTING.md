# Troubleshooting

- Cert-manager: If certs are not issued, check cert-manager pod logs and ClusterIssuer status.
- Helm upgrade fails: Use `helm rollback` to revert. Use `--atomic` to auto rollback on failure.
- ImagePullBackOff: Verify ACR credentials and imagePullSecrets in values-prod.yaml.
