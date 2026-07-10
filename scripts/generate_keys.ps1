param(
  [string]$KeysDir = "./keys"
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command openssl -ErrorAction SilentlyContinue)) {
  Write-Host "OpenSSL not found in PATH. Install OpenSSL and try again." -ForegroundColor Red
  exit 1
}

New-Item -ItemType Directory -Path $KeysDir -Force | Out-Null

$privateKey = Join-Path $KeysDir "private_key.pem"
$publicKey = Join-Path $KeysDir "public_key.pem"

Write-Host "Generating RSA keypair for evidence signing..." -ForegroundColor Cyan
openssl genrsa -out $privateKey 2048 | Out-Null
openssl rsa -in $privateKey -pubout -out $publicKey | Out-Null

Write-Host "Keys generated:" -ForegroundColor Green
Write-Host "  Private key: $privateKey"
Write-Host "  Public key:  $publicKey"
Write-Host ""
Write-Host "Security note: In production, use HSM/KMS instead of file-based keys." -ForegroundColor Yellow
