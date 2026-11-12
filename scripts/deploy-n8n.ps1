# Despliega (o actualiza) n8n en el cluster k3s con el chart local helm/n8n,
# tomando endpoints y credenciales de los outputs de Terraform.
# Version PowerShell del deploy-n8n.sh del profe, adaptada a este proyecto.
#
# Requisitos: terraform apply ya ejecutado, helm y kubectl instalados, y el
# kubeconfig descargado con .\scripts\get-kubeconfig.ps1
#
# Uso (desde la raiz del proyecto):
#   .\scripts\deploy-n8n.ps1
#   .\scripts\deploy-n8n.ps1 -Namespace n8n -Release n8n

param(
  [string]$Namespace = "n8n",
  [string]$Release = "n8n"
)

# "Continue" y no "Stop": PowerShell 5.1 convierte cualquier aviso que kubectl/helm
# escriban en stderr en un error y "Stop" cortaria el script. Cada comando externo
# se valida con $LASTEXITCODE.
$ErrorActionPreference = "Continue"
$env:TF_DISABLE_PLUGIN_TLS = "1"   # AVG intercepta el TLS local de los plugins de Terraform

foreach ($bin in "terraform", "kubectl", "helm") {
  if (-not (Get-Command $bin -ErrorAction SilentlyContinue)) { throw "Falta '$bin' en el PATH (si acabas de instalarlo, abre una terminal nueva)" }
}

function TfOut([string]$name) {
  $v = terraform output -raw $name
  if ($LASTEXITCODE -ne 0 -or -not $v) { throw "No se pudo leer el output '$name' (hiciste terraform apply?)" }
  return $v.Trim()
}

$ws = (terraform workspace show).Trim()
$env:KUBECONFIG = Join-Path $HOME ".kube\k3s-$ws.yaml"
if (-not (Test-Path $env:KUBECONFIG)) { throw "No existe $env:KUBECONFIG. Generalo con .\scripts\get-kubeconfig.ps1" }

$secretName = "n8n-secrets"
Write-Host "Workspace: $ws | kubeconfig: $env:KUBECONFIG | namespace: $Namespace"

# Namespace (idempotente)
kubectl create namespace $Namespace --dry-run=client -o yaml | kubectl apply -f -
if ($LASTEXITCODE -ne 0) { throw "No se pudo crear el namespace $Namespace" }

# Credenciales en un Secret de Kubernetes (no en values ni en el historial de Helm)
kubectl -n $Namespace create secret generic $secretName `
  "--from-literal=DB_POSTGRESDB_PASSWORD=$(TfOut db_password)" `
  "--from-literal=QUEUE_BULL_REDIS_PASSWORD=$(TfOut cache_auth_token)" `
  "--from-literal=N8N_ENCRYPTION_KEY=$(TfOut n8n_encryption_key)" `
  --dry-run=client -o yaml | kubectl apply -f -
if ($LASTEXITCODE -ne 0) { throw "No se pudo crear el Secret $secretName" }

# Hash del Secret: si las credenciales cambian, cambia la anotacion del POD y
# Kubernetes lo recrea; si no cambian, un nuevo deploy no reinicia nada.
$data = kubectl -n $Namespace get secret $secretName -o "jsonpath={.data}"
$sha = [Security.Cryptography.SHA256]::Create()
$checksum = -join ($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($data)) | ForEach-Object { $_.ToString("x2") })

$albDns = TfOut alb_dns

helm upgrade --install $Release .\helm\n8n `
  --namespace $Namespace `
  --set "secretChecksum=$checksum" `
  --set "existingSecret=$secretName" `
  --set "publicHost=$albDns" `
  --set "postgres.host=$(TfOut db_address)" `
  --set "postgres.port=$(TfOut db_port)" `
  --set "postgres.database=$(TfOut db_name)" `
  --set "postgres.user=$(TfOut db_username)" `
  --set "redis.host=$(TfOut cache_address)" `
  --set "redis.port=$(TfOut cache_port)" `
  --wait --timeout 10m
if ($LASTEXITCODE -ne 0) { throw "helm upgrade fallo (revisa los pods: kubectl -n $Namespace get pods)" }

Write-Host ""
Write-Host "n8n disponible en: $(TfOut n8n_url)"
Write-Host "(solo desde la IP de admin_cidr; la primera visita crea la cuenta de administrador)"
