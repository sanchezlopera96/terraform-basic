# Abre un tunel SSH hacia la API de k3s (6443) del master.
# Sirve en redes que bloquean el puerto 6443 pero dejan pasar SSH (22),
# como la red de la universidad.
#
# Uso (desde la raiz del proyecto, en una terminal aparte; Ctrl+C para cerrarlo):
#   .\scripts\tunnel.ps1
#
# Con el tunel abierto, usa un kubeconfig generado con:
#   .\scripts\get-kubeconfig.ps1 -Tunnel

param(
  [string]$KeyPath = "$HOME\.ssh\KP-ITMLab.pem",
  [string]$User = "ec2-user",
  [int]$LocalPort = 16443
)

$env:TF_DISABLE_PLUGIN_TLS = "1"   # AVG intercepta el TLS local de los plugins de Terraform

if (-not (Test-Path $KeyPath)) { throw "No se encontro la llave: $KeyPath" }
$ip = (terraform output -raw master_public_ip).Trim()
if (-not $ip) { throw "No se pudo leer el output master_public_ip (hiciste terraform apply?)" }

Write-Host "Tunel abierto: 127.0.0.1:$LocalPort -> $ip (API k3s :6443). Ctrl+C para cerrarlo."
# ServerAlive* mantiene el tunel vivo aunque no haya trafico por un rato
ssh -i $KeyPath -N -o LogLevel=ERROR -o ExitOnForwardFailure=yes `
  -o ServerAliveInterval=30 -o ServerAliveCountMax=3 `
  -L "${LocalPort}:127.0.0.1:6443" "$User@$ip"
