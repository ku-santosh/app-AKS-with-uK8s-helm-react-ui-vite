# kubectl & helm Cheat Sheet

Helm:
  helm lint ./charts/react-ui
  helm upgrade --install react-ui ./charts/react-ui -f charts/react-ui/values-prod.yaml -n <namespace> --atomic
  helm list -n <namespace>
  helm rollback react-ui <revision> -n <namespace>
  helm uninstall react-ui -n <namespace>

kubectl:
  kubectl get pods -n <ns>
  kubectl logs <pod> -n <ns>
  kubectl exec -it <pod> -n <ns> -- sh
  kubectl apply -f charts/react-ui/cluster-issuer.yaml
