param(
  [Parameter(Mandatory=$true)][string]$EvidenceFile,
  [string]$SignatureFile = "evidence.sig"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $EvidenceFile)) {
  Write-Host "Evidence file not found: $EvidenceFile" -ForegroundColor Red
  exit 1
}

if (-not (Get-Command openssl -ErrorAction SilentlyContinue)) {
  Write-Host "OpenSSL not found in PATH. Install OpenSSL and try again." -ForegroundColor Red
  exit 1
}

$privateKey = Join-Path "./keys" "private_key.pem"
if (-not (Test-Path $privateKey)) {
  Write-Host "Private key not found: $privateKey" -ForegroundColor Red
  Write-Host "Run scripts/generate_keys.ps1 first"
  exit 1
}

Write-Host "Signing evidence bundle: $EvidenceFile" -ForegroundColor Cyan
openssl dgst -sha256 -sign $privateKey -out $SignatureFile $EvidenceFile | Out-Null

$base64Sig = [Convert]::ToBase64String([IO.File]::ReadAllBytes((Resolve-Path $SignatureFile)))

Write-Host "Signature created: $SignatureFile" -ForegroundColor Green
Write-Host "Base64 signature (for JSON):"
Write-Host $base64Sig
Write-Host ""
Write-Host "To verify: node scripts/verify_signature.js $EvidenceFile $base64Sig"
