param(
  [string]$RootPath = "."
)

$ErrorActionPreference = "Stop"
$root = Resolve-Path $RootPath
Set-Location $root

Write-Host "Starting Fraud Trail System (Windows)" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

$envPath = Join-Path $root ".env"
if (-not (Test-Path $envPath)) {
  @"
# Neo4j Configuration
NEO4J_URI=bolt://localhost:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=neo4j

# Server Configuration
PORT=4000
NODE_ENV=development

# Bank Adapter Mock
MOCK_BANK_URL=http://localhost:4001
MOCK_BANK_API_KEY=mock_bank_key

# Exchange Adapter Mock
MOCK_EXCHANGE_URL=http://localhost:4002
MOCK_EXCHANGE_API_KEY=mock_exchange_key
"@ | Set-Content -Path $envPath -Encoding UTF8
  Write-Host "Created .env from defaults" -ForegroundColor Green
}

function Ensure-NodeModules {
  param([string]$Dir)

  $path = Join-Path $root $Dir
  $nodeModules = Join-Path $path "node_modules"
  if (-not (Test-Path $nodeModules)) {
    Write-Host "Installing dependencies in $Dir..." -ForegroundColor Yellow
    Push-Location $path
    npm install
    Pop-Location
  }
}

function Start-ServiceProcess {
  param(
    [string]$Name,
    [string]$Dir,
    [int]$Port
  )

  Ensure-NodeModules -Dir $Dir

  $fullDir = Join-Path $root $Dir
  $command = "Set-Location '$fullDir'; npm start"
  $proc = Start-Process -FilePath "powershell" -ArgumentList "-NoProfile", "-Command", $command -PassThru

  Write-Host ("Started {0} on port {1} (PID: {2})" -f $Name, $Port, $proc.Id) -ForegroundColor Green
  return $proc
}

Write-Host "Checking Neo4j..." -ForegroundColor Yellow
try {
  neo4j status | Out-Null
  if ($LASTEXITCODE -ne 0) {
    neo4j start | Out-Null
    Write-Host "Started Neo4j" -ForegroundColor Green
  } else {
    Write-Host "Neo4j is already running" -ForegroundColor Green
  }
}
catch {
  Write-Host "Neo4j CLI not found in PATH. Start Neo4j manually if needed." -ForegroundColor Yellow
}

$processes = @()
$processes += Start-ServiceProcess -Name "Backend" -Dir "backend" -Port 4000
Start-Sleep -Seconds 2
$processes += Start-ServiceProcess -Name "Mock Bank" -Dir "tools/mock_bank" -Port 4001
Start-Sleep -Seconds 2
$processes += Start-ServiceProcess -Name "Mock Exchange" -Dir "tools/mock_exchange" -Port 4002
Start-Sleep -Seconds 2
$processes += Start-ServiceProcess -Name "Frontend" -Dir "frontend" -Port 3000

$pidFile = Join-Path $root ".service_pids"
($processes | ForEach-Object { $_.Id }) -join " " | Set-Content -Path $pidFile -Encoding UTF8

Write-Host ""
Write-Host "All services started" -ForegroundColor Green
Write-Host "Neo4j Browser:  http://localhost:7474"
Write-Host "Backend API:    http://localhost:4000"
Write-Host "Mock Bank:      http://localhost:4001"
Write-Host "Mock Exchange:  http://localhost:4002"
Write-Host "Frontend UI:    http://localhost:3000"
Write-Host ""

Read-Host "Press Enter to stop services"

foreach ($proc in $processes) {
  if (-not $proc.HasExited) {
    Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
  }
}

if (Test-Path $pidFile) {
  Remove-Item $pidFile -Force
}

Write-Host "Stopped all services" -ForegroundColor Green
