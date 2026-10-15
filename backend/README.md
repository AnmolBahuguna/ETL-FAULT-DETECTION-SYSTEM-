# 🚀 Blockchain Monitoring Service

A complete real-time blockchain monitoring service built from scratch - similar to Alchemy and Moralis, but **without using their APIs**.

## ✨ Features

- ✅ **Real-time block monitoring** (WebSocket + polling fallback)
- ✅ **Transaction tracking** for any wallet address
- ✅ **Token transfer detection** (ERC20)
- ✅ **NFT transfer detection** (ERC721/ERC1155)
- ✅ **Contract interaction detection**
- ✅ **Balance change tracking**
- ✅ **Event log parsing**
- ✅ **Webhook notifications** (configurable per address)
- ✅ **WebSocket server** for real-time frontend updates
- ✅ **REST API** for managing tracked addresses
- ✅ **Multi-chain ready** (currently Ethereum, easily extensible)

## 🚀 Quick Start

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Configure Environment

```bash
cp ../.env.example .env
# Edit .env with your RPC endpoints
```

### 3. Start the Server

```bash
node server.js
# or for development:
npx nodemon server.js
```

Run these commands from the `backend/` directory. This starts the separate blockchain monitoring service on `http://localhost:5001` by default.

> **Dependency note:** The monitoring service imports `ethers`, but `ethers` is not currently declared in `backend/package.json`. A clean `npm install` therefore does not install this required dependency; the service needs that manifest issue resolved before it can start from a clean checkout.

The backend package's `npm start` command starts the Fraud Trail API in `src/index.js` on port `4000`, not this monitoring service.

## 📡 API Endpoints

### Track Addresses

```bash
# Add address to track
curl -X POST http://localhost:5001/api/track/address \
  -H "Content-Type: application/json" \
  -d '{"address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"}'

# List tracked addresses
curl http://localhost:5001/api/track/addresses

# Remove address
curl -X DELETE http://localhost:5001/api/track/address/0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb
```

### Get Transactions

```bash
# Get recent transactions
curl http://localhost:5001/api/transactions?limit=50

# Get transactions for specific address
curl http://localhost:5001/api/transactions/0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb

# Get all activities (tokens, NFTs, etc.)
curl http://localhost:5001/api/transactions/activities/all?limit=100
```

### Configure Webhooks

```bash
# Configure webhook for an address
curl -X POST http://localhost:5001/api/webhooks/config \
  -H "Content-Type: application/json" \
  -d '{
    "address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
    "webhookUrl": "https://your-server.com/webhook",
    "secret": "your-secret-key"
  }'

# Test webhook
curl -X POST http://localhost:5001/api/webhooks/test \
  -H "Content-Type: application/json" \
  -d '{
    "address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
    "webhookUrl": "https://your-server.com/webhook"
  }'
```

### Blockchain Info

```bash
# Get current block number
curl http://localhost:5001/api/blockchain/block/current

# Get system status
curl http://localhost:5001/api/blockchain/status
```

## 🔌 WebSocket Connection

Connect to `ws://localhost:5001` to receive real-time updates:

```javascript
const ws = new WebSocket('ws://localhost:5001');

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  
  if (data.type === 'ACTIVITY') {
    console.log('New activity:', data.data);
  } else if (data.type === 'BLOCK') {
    console.log('New block:', data.data.blockNumber);
  }
};
```

## 📦 Webhook Payload

When activity is detected, your webhook URL will receive:

```json
{
  "event": "ADDRESS_ACTIVITY",
  "chain": "ethereum",
  "address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
  "activity": [
    {
      "type": "TRANSACTION",
      "hash": "0x...",
      "from": "0x...",
      "to": "0x...",
      "value": "1000000000000000000",
      "valueEth": "1.0",
      "activities": [
        {
          "type": "ETH_TRANSFER",
          "from": "0x...",
          "to": "0x...",
          "value": "1000000000000000000"
        },
        {
          "type": "TOKEN_TRANSFER",
          "standard": "ERC20",
          "contract": "0x...",
          "from": "0x...",
          "to": "0x...",
          "value": "1000000"
        }
      ],
      "balanceChange": {
        "balanceBefore": "1000000000000000000",
        "balanceAfter": "2000000000000000000",
        "balanceDelta": "1000000000000000000"
      }
    }
  ],
  "timestamp": "2025-01-18T12:00:00Z",
  "signature": "hmac-sha256-signature-if-secret-configured"
}
```

## 🏗️ Architecture

```
Backend Server
├── Blockchain Monitor (scans blocks)
├── Transaction Analyzer (detects transfers, tokens, NFTs)
├── Balance Tracker (tracks balance changes)
├── Webhook Delivery (sends notifications)
├── WebSocket Server (real-time updates)
└── REST API (management endpoints)
```

## 🔧 Configuration

Edit `.env` file:

```env
PORT=5001
ETHEREUM_RPC_URL=https://eth.llamarpc.com
ETHEREUM_WS_URL=wss://eth.llamarpc.com
CHAIN_NAME=ethereum
```

## 📊 What Gets Tracked

For each tracked address, the service monitors:

1. **ETH Transfers** - Incoming and outgoing native currency
2. **Token Transfers** - ERC20 token movements
3. **NFT Transfers** - ERC721 and ERC1155 transfers
4. **Contract Interactions** - Function calls to smart contracts
5. **Balance Changes** - Before/after balance tracking
6. **Event Logs** - All events emitted by contracts

## 🎯 Use Cases

- **Fraud Detection** - Track scammer wallets in real-time
- **Portfolio Tracking** - Monitor your wallet activity
- **DEX Monitoring** - Track DEX swaps and liquidity movements
- **NFT Tracking** - Monitor NFT transfers and mints
- **Cross-chain Monitoring** - Track funds across chains
- **Compliance** - Monitor transactions for regulatory purposes

## 🚧 Future Enhancements

- [ ] Multi-chain support (Polygon, BSC, Arbitrum)
- [ ] Database persistence (MongoDB)
- [ ] Webhook retry queue
- [ ] Rate limiting
- [ ] Authentication/Authorization
- [ ] Token price integration
- [ ] Transaction graph visualization
- [ ] Alert system (email, SMS, etc.)

## 📝 License

MIT
