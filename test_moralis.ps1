param(
  [string]$BaseUrl = "http://localhost:4000"
)

$ErrorActionPreference = "Stop"

function Invoke-JsonGet {
  param(
    [Parameter(Mandatory=$true)][string]$Url
  )

  $resp = Invoke-RestMethod -Method Get -Uri $Url -Headers @{ Accept = "application/json" }
  $resp | ConvertTo-Json -Depth 20
}

function Invoke-JsonPost {
  param(
    [Parameter(Mandatory=$true)][string]$Url,
    [Parameter(Mandatory=$true)][object]$Body
  )

  $json = $Body | ConvertTo-Json -Depth 20
  $resp = Invoke-RestMethod -Method Post -Uri $Url -ContentType "application/json" -Body $json -Headers @{ Accept = "application/json" }
  $resp | ConvertTo-Json -Depth 20
}

Write-Host "Testing Moralis API Integration" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

try {
  Write-Host "1. Checking Moralis health..." -ForegroundColor Yellow
  Invoke-JsonGet "$BaseUrl/api/moralis/health"
  Write-Host ""

  $address = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"
  Write-Host "2. Testing fetch for wallet: $address" -ForegroundColor Yellow
  Write-Host "   (This will use real Moralis API if key is set)"
  Write-Host ""

  $transfersUrl = "$BaseUrl/api/moralis/address/$address/transfers?chain=eth&limit=5"
  $transfersJson = Invoke-JsonGet $transfersUrl
  ($transfersJson -split "`n" | Select-Object -First 30) -join "`n"
  Write-Host ""

  Write-Host "3. Testing fetch-and-ingest endpoint..." -ForegroundColor Yellow
  Invoke-JsonPost "$BaseUrl/api/moralis/fetch-and-ingest" @{ address = $address; chain = "eth"; limit = 10 }
  Write-Host ""

  Write-Host "Test complete!" -ForegroundColor Green
  Write-Host ""
  Write-Host "If you see 'hasApiKey: true' and real transfer data, Moralis is working!" -ForegroundColor Cyan
}
catch {
  Write-Host "Request failed:" -ForegroundColor Red
  Write-Host $_
  exit 1
}
