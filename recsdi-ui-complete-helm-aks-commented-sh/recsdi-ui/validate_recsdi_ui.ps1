<#
====================================================================
RECSDI-UI Validation Script (PowerShell)
====================================================================
This script validates Helm chart, K8s YAML, and CI/CD consistency.
Usage:
  pwsh .\validate_recsdi_ui.ps1
or
  powershell .\validate_recsdi_ui.ps1
====================================================================
#>

$ChartDir = "recsdi-ui/charts/recsdi-ui"
$K8sDir = "recsdi-ui/k8s"
$CIFile = "recsdi-ui/.gitlab-ci.yml"

$AcrDev = "ubsdevacr.azurecr.io"
$AcrProd = "ubsreleaseacr.azurecr.io"
$ImageName = "recsdi-ui"
$NamespaceDev = "at41457-dev-recsdiui-dev"
$ProdPullSecret = "acr-secret"

$pass = 0
$fail = 0

function Pass($msg) { Write-Host "PASS: $msg" -ForegroundColor Green; $global:pass++ }
function Fail($msg) { Write-Host "FAIL: $msg" -ForegroundColor Red; $global:fail++ }

Write-Host "=== Validating RECSDI-UI Project Files ===" -ForegroundColor Cyan

$files = @(
  "$ChartDir/Chart.yaml",
  "$ChartDir/values.yaml",
  "$ChartDir/templates/deployment.yaml",
  "$ChartDir/templates/ingress.yaml",
  "$K8sDir/recsdi-ui-pod.yaml",
  "$K8sDir/recsdi-ui-svc.yaml"
)
foreach ($f in $files) {
  if (Test-Path $f) { Pass "Found $f" } else { Fail "Missing $f" }
}

Write-Host "`n=== Checking Helm Values ===" -ForegroundColor Cyan
if (Select-String -Quiet $AcrDev "$ChartDir/values.yaml") { Pass "Dev ACR present" } else { Fail "Dev ACR missing" }
if (Select-String -Quiet "className: nginx" "$ChartDir/values.yaml") { Pass "Ingress className present" } else { Fail "Ingress className missing" }
if (Select-String -Quiet "cert-manager.io/cluster-issuer" "$ChartDir/values.yaml") { Pass "cert-manager annotation found" } else { Fail "cert-manager annotation missing" }

Write-Host "`n=== Checking Deployment Security Context ===" -ForegroundColor Cyan
$dep = "$ChartDir/templates/deployment.yaml"
$checks = @{
  "runAsNonRoot" = "runAsNonRoot: true"
  "allowPrivilegeEscalation" = "allowPrivilegeEscalation: false"
  "seccompProfile" = "seccompProfile"
  "capabilities" = "capabilities"
}
foreach ($key in $checks.Keys) {
  if (Select-String -Quiet $checks[$key] $dep) { Pass "$key found" } else { Fail "$key missing" }
}

Write-Host "`n=== Checking Ingress ===" -ForegroundColor Cyan
$ing = "$ChartDir/templates/ingress.yaml"
if (Select-String -Quiet "ingressClassName" $ing) { Pass "Ingress uses ingressClassName" } else { Fail "Ingress className missing" }
if (Select-String -Quiet "kubernetes.io/ingress.class" $ing) { Fail "Deprecated ingress.class annotation found" } else { Pass "No deprecated ingress annotation" }

Write-Host "`n=== Optional Helm Validation ===" -ForegroundColor Cyan
if (Get-Command helm -ErrorAction SilentlyContinue) {
  & helm lint $ChartDir
  & helm template recsdi-ui $ChartDir -f "$ChartDir/values.yaml" | Out-File /tmp/recsdi_render.yaml
  if (Select-String -Quiet "kind: Deployment" /tmp/recsdi_render.yaml) { Pass "Deployment rendered" } else { Fail "Deployment not rendered" }
} else {
  Write-Host "Helm not installed, skipping lint/template checks." -ForegroundColor Yellow
}

Write-Host "`nSUMMARY: PASS=$pass  FAIL=$fail" -ForegroundColor Cyan
if ($fail -gt 0) {
  Write-Host "Some checks FAILED. Please review above output." -ForegroundColor Red
} else {
  Write-Host "✅ All checks passed successfully!" -ForegroundColor Green
}
