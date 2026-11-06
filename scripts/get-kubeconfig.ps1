# Descarga el kubeconfig del master k3s y lo deja listo para kubectl / OpenLens.
#
# Uso (desde la raiz del proyecto, con las credenciales del lab vigentes):
#   .\scripts\get-kubeconfig.ps1
#   .\scripts\get-kubeconfig.ps1 -KeyPath C:\ruta\a\mi-llave.pem
#
# Resultado: $HOME\.kube\k3s-<workspace>.yaml
#   - El server apunta a la IP publica del master (k3s se instala con --tls-san <ip>).
#   - El contexto se llama k3s-<workspace> en vez de "default".

param(
  [string]$KeyPath = "$HOME\.ssh\KP-ITMLab.pem",
  [string]$User = "ec2-user"
)

$ErrorActionPreference = "Stop"
$env:TF_DISABLE_PLUGIN_TLS = "1"   # AVG intercepta el TLS local de los plugins de Terraform

if (-not (Test-Path $KeyPath)) { throw "No se encontro la llave: $KeyPath" }

$ip = (terraform output -raw master_public_ip).Trim()
$ws = (terraform workspace show).Trim()
if (-not $ip) { throw "No se pudo leer el output master_public_ip (hiciste terraform apply?)" }

$name = "k3s-$ws"
$kubeDir = Join-Path $HOME ".kube"
$target = Join-Path $kubeDir "$name.yaml"
New-Item -ItemType Directory -Force $kubeDir | Out-Null

Write-Host "Descargando kubeconfig desde $User@$ip ..."
$raw = ssh -i $KeyPath -o StrictHostKeyChecking=accept-new "$User@$ip" "cat /etc/rancher/k3s/k3s.yaml"
if ($LASTEXITCODE -ne 0 -or -not $raw) {
  throw "No se pudo leer /etc/rancher/k3s/k3s.yaml (k3s puede seguir instalandose; espera unos minutos)"
}

$config = ($raw -join "`n") `
  -replace "https://127\.0\.0\.1:6443", "https://${ip}:6443" `
  -replace "(?m)^(\s*(?:-\s+)?(?:name|cluster|user|current-context):\s*)default\s*$", "`${1}$name"

# UTF-8 sin BOM (kubectl no acepta el BOM)
[IO.File]::WriteAllText($target, $config + "`n", (New-Object Text.UTF8Encoding $false))

Write-Host ""
Write-Host "Kubeconfig guardado en: $target"
Write-Host "Probar:   kubectl --kubeconfig `"$target`" get nodes"
Write-Host "OpenLens: File > Add Cluster > pegar el contenido del archivo (o agregar la carpeta $kubeDir)"
