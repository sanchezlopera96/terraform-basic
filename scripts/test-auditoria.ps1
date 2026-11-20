# Prueba la API de auditoria de inventario (workflow n8n-workflows/auditoria-inventario-api.json).
#
# Uso (desde la raiz del proyecto):
#   .\scripts\test-auditoria.ps1           # URL de produccion (workflow publicado)
#   .\scripts\test-auditoria.ps1 -Test     # URL de prueba (con "Execute workflow" escuchando en el editor)

param([switch]$Test)

$env:TF_DISABLE_PLUGIN_TLS = "1"   # AVG intercepta el TLS local de los plugins de Terraform

$base = (terraform output -raw n8n_url).Trim().TrimEnd('/')
$path = if ($Test) { "webhook-test" } else { "webhook" }
$uri = "$base/$path/auditoria"

# bodegaA es la fuente de verdad; bodegaB es la que se quiere sincronizar
$body = @{
  bodegaA = @(
    @{ product_id = "P-001"; name = "Keyboard"; stock = 200 },
    @{ product_id = "P-002"; name = "Mouse";    stock = 150 },
    @{ product_id = "P-003"; name = "Webcam";   stock = 75 }
  )
  bodegaB = @(
    @{ product_id = "P-001"; name = "Keyboard"; stock = 200 },
    @{ product_id = "P-002"; name = "Mouse";    stock = 100 },
    @{ product_id = "P-004"; name = "Monitor";  stock = 50 }
  )
} | ConvertTo-Json -Depth 5

Write-Host "POST $uri"
$r = Invoke-RestMethod -Method Post -Uri $uri -ContentType "application/json" -Body $body
$r | Format-Table product_id, name, stock, accion -AutoSize
