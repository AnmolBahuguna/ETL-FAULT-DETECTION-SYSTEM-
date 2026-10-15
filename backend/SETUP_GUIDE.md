# 🚀 Setup Guide - Blockchain Monitoring Service

## Step-by-Step Installation

### 1. Navigate to Backend Directory

```bash
cd ETH_FraudDetection_System/backend
```

### 2. Install Dependencies

```bash
npm install
```

This will install:
- `express` - Web server
- `ws` - WebSocket server
- `axios` - HTTP requests for webhooks
- `cors` - Cross-origin support
- `dotenv` - Environment variables

> **Dependency note:** The monitoring service imports `ethers`, but `ethers` is not currently declared in `backend/package.json`. A clean `npm install` therefore does not install this required dependency; the service needs that manifest issue resolved before it can start from a clean checkout.

### 3. Create Environment File

Create a file named `.env` in the `backend` directory:

```env
PORT=5001
ETHEREUM_RPC_URL=https://eth.llamarpc.com
ETHEREUM_WS_URL=wss://eth.llamarpc.com
CHAIN_NAME=ethereum
```

**Alternative RPC URLs (no API key needed):**
- `https://rpc.ankr.com/eth`
- `https://ethereum.publicnode.com`
- `https://eth-mainnet.public.blastapi.io`

### 4. Start the Server

```bash
node server.js
```

For development with auto-reload:
```bash
npx nodemon server.js
```

Run these commands from the `backend/` directory. The backend package's `npm start` command starts the separate Fraud Trail API in `src/index.js` on port `4000`; it does not start this monitoring service.

You should see:
```
🚀 Initializing Blockchain Monitoring Service...
📍 Chain: ethereum
🔗 RPC URL: https://eth.llamarpc.com
🔌 WebSocket: Enabled

✅ Server running on port 5001
📡 WebSocket server ready: ws://localhost:5001
🌐 HTTP API: http://localhost:5001
🔍 Blockchain monitoring active for ethereum
```

### 5. Test the Service

Open a new terminal and test:

```bash
# Health check
curl http://localhost:5001/health

# Add an address to track
curl -X POST http://localhost:5001/api/track/address \
  -H "Content-Type: application/json" \
  -d '{"address": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"}'

# Check tracked addresses
curl http://localhost:5001/api/track/addresses

# Get system status
curl http://localhost:5001/api/blockchain/status
```

## 🎯 Quick Test Example

1. **Add a wallet to track:**
   ```bash
   curl -X POST http://localhost:5001/api/track/address \
     -H "Content-Type: application/json" \
     -d '{"address": "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045"}'
   ```

2. **Configure a webhook (optional):**
   ```bash
   curl -X POST http://localhost:5001/api/webhooks/config \
     -H "Content-Type: application/json" \
     -d '{
       "address": "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045",
       "webhookUrl": "https://webhook.site/your-unique-url"
     }'
   ```

3. **Monitor transactions:**
   - Watch the server console for activity
   - Check transactions: `curl http://localhost:5001/api/transactions`
   - Connect WebSocket client to `ws://localhost:5001`

## 🔧 Troubleshooting

### Port Already in Use
```bash
# Change PORT in .env file
PORT=5002
```

### RPC Connection Failed
- Try a different RPC URL from the list above
- Check your internet connection
- Some RPCs may have rate limits

### WebSocket Not Working
- The service will automatically fall back to polling
- Check if your RPC provider supports WebSocket
- Polling works fine, just slightly less real-time

### No Transactions Detected
- Make sure the address you're tracking has recent activity
- Check that the address is valid (starts with 0x, 42 characters)
- Wait for new blocks to be mined (Ethereum ~12 seconds per block)

## 📚 Next Steps

1. Integrate with your frontend (see frontend examples)
2. Set up webhooks for your fraud detection system
3. Add more addresses to track
4. Monitor the WebSocket for real-time updates

## 🎉 You're Ready!

Your blockchain monitoring service is now running and ready to track wallet activity in real-time!
