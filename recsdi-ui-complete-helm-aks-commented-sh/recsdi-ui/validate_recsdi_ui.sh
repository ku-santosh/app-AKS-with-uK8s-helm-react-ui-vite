#!/usr/bin/env bash
# ============================================================
# RECSDI-UI Validation Script
# ============================================================
# This script validates Helm, K8s, and CI/CD configuration consistency.
# Usage: chmod +x validate_recsdi_ui.sh && ./validate_recsdi_ui.sh
# ============================================================

set -u

ROOT_DIR="."
CHART_DIR="$ROOT_DIR/recsdi-ui/charts/recsdi-ui"
K8S_DIR="$ROOT_DIR/recsdi-ui/k8s"
CI_FILE="$ROOT_DIR/recsdi-ui/.gitlab-ci.yml"

ACR_DEV="ubsdevacr.azurecr.io"
ACR_PROD="ubsreleaseacr.azurecr.io"
IMAGE_NAME="recsdi-ui"
NAMESPACE_DEV="at41457-dev-recsdiui-dev"
NAMESPACE_UAT="at41457-uat-recsdiui-uat"
NAMESPACE_PROD="at41457-prod-recsdiui-prod"
PROD_PULL_SECRET="acr-secret"

passcount=0
failcount=0

function pass() { echo -e "\033[32mPASS:\033[0m $1"; passcount=$((passcount+1)); }
function fail() { echo -e "\033[31mFAIL:\033[0m $1"; failcount=$((failcount+1)); }

function file_exists {
  if [[ -f "$1" ]]; then pass "Found $1"; else fail "Missing $1"; fi
}

echo "=== Validating RECSDI-UI Project Files ==="
for f in   "$CHART_DIR/Chart.yaml"   "$CHART_DIR/values.yaml"   "$CHART_DIR/templates/deployment.yaml"   "$CHART_DIR/templates/ingress.yaml"   "$K8S_DIR/recsdi-ui-pod.yaml"   "$K8S_DIR/recsdi-ui-svc.yaml"; do
  file_exists "$f"
done

echo
echo "=== Checking Helm Values ==="
grep -q "$ACR_DEV" "$CHART_DIR/values.yaml" && pass "Dev ACR present in values.yaml" || fail "Dev ACR missing in values.yaml"
grep -q "className: nginx" "$CHART_DIR/values.yaml" && pass "Ingress className present" || fail "Ingress className missing"
grep -q "cert-manager.io/cluster-issuer" "$CHART_DIR/values.yaml" && pass "cert-manager annotation found" || fail "cert-manager annotation missing"

echo
echo "=== Checking Deployment Security Context ==="
DEPLOY_FILE="$CHART_DIR/templates/deployment.yaml"
grep -q "runAsNonRoot: true" "$DEPLOY_FILE" && pass "runAsNonRoot found" || fail "runAsNonRoot missing"
grep -q "allowPrivilegeEscalation: false" "$DEPLOY_FILE" && pass "allowPrivilegeEscalation found" || fail "allowPrivilegeEscalation missing"
grep -q "seccompProfile" "$DEPLOY_FILE" && pass "seccompProfile present" || fail "seccompProfile missing"
grep -q "capabilities" "$DEPLOY_FILE" && grep -q "drop:" "$DEPLOY_FILE" && grep -q "ALL" "$DEPLOY_FILE" && pass "Capabilities drop ALL present" || fail "Capabilities drop ALL missing"

echo
echo "=== Checking Ingress File ==="
INGRESS_FILE="$CHART_DIR/templates/ingress.yaml"
grep -q "ingressClassName" "$INGRESS_FILE" && pass "Ingress uses ingressClassName" || fail "Ingress className missing"
grep -q "kubernetes.io/ingress.class" "$INGRESS_FILE" && fail "Deprecated ingress.class annotation found" || pass "No deprecated ingress annotation"

echo
echo "=== Optional Helm Checks ==="
if command -v helm >/dev/null 2>&1; then
  helm lint "$CHART_DIR"
  helm template recsdi-ui "$CHART_DIR" -f "$CHART_DIR/values.yaml" > /tmp/recsdi_render.yaml
  grep -q "kind: Deployment" /tmp/recsdi_render.yaml && pass "Deployment rendered" || fail "Deployment not rendered"
else
  echo "Helm not installed - skipping lint checks."
fi

echo
echo "Validation complete. PASS=$passcount, FAIL=$failcount"
if [[ $failcount -gt 0 ]]; then
  echo "Some checks failed. Please review above output."
else
  echo "✅ All checks passed successfully!"
fi
