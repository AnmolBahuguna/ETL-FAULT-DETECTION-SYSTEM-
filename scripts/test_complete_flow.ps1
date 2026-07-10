param(
  [string]$ApiBase = "http://localhost:4000"
)

$ErrorActionPreference = "Stop"
$caseId = "CASE-FLOW-TEST-$(Get-Date -UFormat %s)"
$utr = "UTR123456789"

function Invoke-Api {
  param(
    [ValidateSet("GET", "POST")][string]$Method,
    [string]$Url,
    [object]$Body
  )

  if ($Method -eq "GET") {
    return Invoke-RestMethod -Method Get -Uri $Url -Headers @{ Accept = "application/json" }
  }

  $json = $Body | ConvertTo-Json -Depth 20
  return Invoke-RestMethod -Method Post -Uri $Url -ContentType "application/json" -Body $json -Headers @{ Accept = "application/json" }
}

Write-Host "Starting Complete Freeze Flow Test" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Step 1: Submitting fraud case..." -ForegroundColor Yellow
$null = Invoke-Api -Method POST -Url "$ApiBase/api/fabric/submit-evidence" -Body @{
  caseId = $caseId
  evidenceHash = "sha256:test-evidence-$(Get-Date -UFormat %s)"
  requester = "bank:HDFC"
}
Write-Host "Case submitted: $caseId" -ForegroundColor Green
Write-Host ""

Write-Host "Step 2: Running automated trace from UTR..." -ForegroundColor Yellow
$traceResponse = Invoke-Api -Method POST -Url "$ApiBase/api/automated-trace/utr-with-assets" -Body @{
  utr = $utr
  chain = "eth"
  depth = 6
  hours = 168
}

$assetRefs = @($traceResponse.asset_refs)
if (-not $assetRefs -or $assetRefs.Count -eq 0) {
  Write-Host "No asset references from trace, using defaults for test." -ForegroundColor Yellow
  $assetRefs = @(
    "bank:abc123def456",
    "exchange:P2P-ORDER-001",
    "chain:0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"
  )
}

Write-Host "Asset references:" -ForegroundColor Green
$assetRefs | ForEach-Object { Write-Host "  - $_" }
Write-Host ""

Write-Host "Step 3: Requesting freeze..." -ForegroundColor Yellow
$freezeRequest = Invoke-Api -Method POST -Url "$ApiBase/api/freeze/request" -Body @{
  caseId = $caseId
  evidenceHash = "sha256:test-evidence"
  requestedBy = "LEA:IndiaCyber"
  severity = "high"
  assetRefs = $assetRefs
}
$freezeRequest | ConvertTo-Json -Depth 20
Write-Host ""

Write-Host "Step 4: Checking freeze status..." -ForegroundColor Yellow
$statusResponse = Invoke-Api -Method GET -Url "$ApiBase/api/freeze/status/$caseId"
$statusResponse | ConvertTo-Json -Depth 20
Write-Host ""

Write-Host "Step 5: Approving freeze (3 approvals required)..." -ForegroundColor Yellow
$approvers = @("bank:HDFC", "bank:ICICI", "LEA:IndiaCyber")
foreach ($approver in $approvers) {
  $approve = Invoke-Api -Method POST -Url "$ApiBase/api/freeze/approve" -Body @{
    caseId = $caseId
    approver = $approver
  }

  [PSCustomObject]@{
    approver = $approver
    currentApprovals = $approve.currentApprovals
    requiredApprovals = $approve.requiredApprovals
    freeze_activated = $approve.freeze_activated
  } | ConvertTo-Json -Depth 10
}
Write-Host ""

Write-Host "Step 6: Final freeze status..." -ForegroundColor Yellow
$finalStatus = Invoke-Api -Method GET -Url "$ApiBase/api/freeze/status/$caseId"
$finalStatus | ConvertTo-Json -Depth 20
Write-Host ""

Write-Host "Complete flow test finished" -ForegroundColor Green
Write-Host "Case ID: $caseId"
