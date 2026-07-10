$ErrorActionPreference = "Stop"

Write-Host "Reloading Mock Data..." -ForegroundColor Cyan
Write-Host ""

try {
  Invoke-WebRequest -UseBasicParsing -Uri "http://localhost:4001/api/bank/utr/UTR-FREEZE-001" -TimeoutSec 5 | Out-Null
}
catch {
  Write-Host "Mock Bank (port 4001) is not running" -ForegroundColor Red
  Write-Host "Start it: Set-Location tools/mock_bank; node server.js"
  exit 1
}

try {
  Invoke-WebRequest -UseBasicParsing -Uri "http://localhost:4002/api/exchange/lea/query" -TimeoutSec 5 | Out-Null
}
catch {
  Write-Host "Mock Exchange (port 4002) is not running" -ForegroundColor Red
  Write-Host "Start it: Set-Location tools/mock_exchange; node server.js"
  exit 1
}

Write-Host "Both mock services are running" -ForegroundColor Green
Write-Host ""
Write-Host "Mock services load data on startup. To reload data, restart both servers:" -ForegroundColor Yellow
Write-Host "  1. Stop mock_bank"
Write-Host "  2. Stop mock_exchange"
Write-Host "  3. Start them again from tools/mock_bank and tools/mock_exchange"
Write-Host ""
Write-Host "Or run: node scripts/load_complete_mock_data.js"
