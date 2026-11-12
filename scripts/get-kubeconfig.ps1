# Descarga el kubeconfig del master k3s y lo deja listo para kubectl / OpenLens.
#
# Uso (desde la raiz del proyecto, con las credenciales del lab vigentes):
#   .\scripts\get-kubeconfig.ps1
#   .\scripts\get-kubeconfig.ps1 -KeyPath C:\ruta\a\mi-llave.pem
#
# Resultado: $HOME\.kube\k3s-<workspace>.yaml
#   - El server apunta a la IP publica del master (k3s se instala con --tls-san <ip>).
#   - El contexto se llama k3s-<workspace> en vez de "default".

#   .\scripts\get-kubeconfig.ps1 -Tunnel
#     Para redes que bloquean el puerto 6443 (p.ej. la de la universidad): el server
#     queda en https://127.0.0.1:<LocalPort> y se usa con .\scripts\tunnel.ps1 abierto.

param(
  [string]$KeyPath = "$HOME\.ssh\KP-ITMLab.pem",
  [string]$User = "ec2-user",
  [switch]$Tunnel,
  [int]$LocalPort = 16443
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
# PowerShell 5.1 convierte cualquier texto de stderr de un comando externo (p.ej. el
# aviso "Permanently added ... to known hosts") en error; con "Stop" cortaria el
# script. Los errores reales se detectan por $LASTEXITCODE.
$ErrorActionPreference = "Continue"
$raw = ssh -i $KeyPath -o StrictHostKeyChecking=accept-new -o LogLevel=ERROR "$User@$ip" "cat /etc/rancher/k3s/k3s.yaml"
$ErrorActionPreference = "Stop"
if ($LASTEXITCODE -ne 0 -or -not $raw) {
  throw "No se pudo leer /etc/rancher/k3s/k3s.yaml (k3s puede seguir instalandose; espera unos minutos)"
}

# Directo: IP publica del master. Tunel: puerto local que reenvia tunnel.ps1
# (el certificado de k3s ya incluye 127.0.0.1, asi que TLS valida igual).
$server = if ($Tunnel) { "https://127.0.0.1:$LocalPort" } else { "https://${ip}:6443" }

$config = ($raw -join "`n") `
  -replace "https://127\.0\.0\.1:6443", $server `
  -replace "(?m)^(\s*(?:-\s+)?(?:name|cluster|user|current-context):\s*)default\s*$", "`${1}$name"

# UTF-8 sin BOM (kubectl no acepta el BOM)
[IO.File]::WriteAllText($target, $config + "`n", (New-Object Text.UTF8Encoding $false))

Write-Host ""
Write-Host "Kubeconfig guardado en: $target  (server: $server)"
if ($Tunnel) { Write-Host "Modo tunel: deja abierto .\scripts\tunnel.ps1 en otra terminal mientras usas kubectl, helm u OpenLens" }
Write-Host "Probar:   kubectl --kubeconfig `"$target`" get nodes"
Write-Host "OpenLens: File > Add Cluster > pegar el contenido del archivo (o agregar la carpeta $kubeDir)"
