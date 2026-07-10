# Windows Setup Guide

This project now supports native Windows PowerShell workflows.

## Prerequisites

- Node.js 18+
- npm
- PowerShell 5+ or PowerShell 7+
- Neo4j Desktop or Neo4j service (optional if using memory graph)
- OpenSSL in PATH (required for key generation/signing scripts)

## 1) Install dependencies

Run from project root in PowerShell:

```powershell
Set-Location .\ETH_FraudDetection_System

Set-Location backend
npm install
Set-Location ..

Set-Location frontend
npm install
Set-Location ..

Set-Location tools\mock_bank
npm install
Set-Location ..\..

Set-Location tools\mock_exchange
npm install
Set-Location ..\..
```

## 2) Start all services

```powershell
./start-services.ps1
```

This starts:
- Backend on port 4000
- Mock Bank on port 4001
- Mock Exchange on port 4002
- Frontend on port 3000

## 3) Test core flows

```powershell
./test_moralis.ps1
./backend/test-crosschain-simple.ps1
./backend/test-crosschain-swap.ps1
./scripts/test_complete_flow.ps1
```

## 4) Evidence signing scripts

```powershell
./scripts/generate_keys.ps1
./scripts/sign_bundle.ps1 -EvidenceFile .\demo\complete_mock_dataset.json
node .\scripts\verify_signature.js .\demo\complete_mock_dataset.json "<base64-signature>"
```

## 5) Useful Windows commands

Check port usage:

```powershell
netstat -ano | findstr :4000
```

Stop all Node processes:

```powershell
Get-Process node -ErrorAction SilentlyContinue | Stop-Process -Force
```

Open UI:

```powershell
start http://localhost:3000
```
