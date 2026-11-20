# Envia los Excel de las dos bodegas a la API de auditoria de n8n
# (workflow n8n-workflows/auditoria-inventario-excel.json) y muestra el reporte.
#
# Estructura esperada de la carpeta (por defecto .\datos):
#   datos\
#     bodegaA\productos.xlsx   <- fuente de verdad
#     bodegaB\productos.xlsx   <- bodega a revisar
# Cada Excel: columnas product_id, name, stock (fila 1 = encabezados).
#
# Uso (desde la raiz del proyecto):
#   .\scripts\auditoria-excel.ps1                    # URL de produccion (workflow publicado)
#   .\scripts\auditoria-excel.ps1 -Test              # URL de prueba ("Execute workflow" escuchando)
#   .\scripts\auditoria-excel.ps1 -Carpeta D:\otra   # otra carpeta con la misma estructura

param(
  [string]$Carpeta = ".\datos",
  [switch]$Test
)

$ErrorActionPreference = "Continue"
$env:TF_DISABLE_PLUGIN_TLS = "1"   # AVG intercepta el TLS local de los plugins de Terraform

# Toma el primer .xlsx de cada subcarpeta (no importa el nombre del archivo)
function Get-Excel([string]$bodega) {
  $dir = Join-Path $Carpeta $bodega
  $f = Get-ChildItem -Path $dir -Filter *.xlsx -File -ErrorAction SilentlyContinue | Select-Object -First 1
  if (-not $f) { throw "No hay ningun .xlsx en $dir" }
  return $f.FullName
}

$fileA = Get-Excel "bodegaA"
$fileB = Get-Excel "bodegaB"

$base = (terraform output -raw n8n_url).Trim().TrimEnd('/')
if (-not $base) { throw "No se pudo leer el output n8n_url (hiciste terraform apply?)" }
$path = if ($Test) { "webhook-test" } else { "webhook" }
$uri = "$base/$path/auditoria-excel"

$mime = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
Write-Host "POST $uri"
Write-Host "  bodegaA = $fileA"
Write-Host "  bodegaB = $fileB"

# Invoke-RestMethod de PowerShell 5.1 no soporta multipart (-Form es de PowerShell 7): se usa curl.exe
$raw = curl.exe -s -S --fail-with-body -X POST $uri `
  -F "bodegaA=@$fileA;type=$mime" `
  -F "bodegaB=@$fileB;type=$mime"
if ($LASTEXITCODE -ne 0) { throw "La llamada fallo (codigo $LASTEXITCODE): $raw" }

$r = ($raw -join "`n") | ConvertFrom-Json
$r | Format-Table product_id, name, stock, accion -AutoSize
