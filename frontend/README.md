# MonadCLOB Frontend

Modern TypeScript React frontend for MonadCLOB - A parallel-friendly on-chain CLOB DEX.

## Tech Stack

- **React 18** - UI library
- **TypeScript** - Type safety
- **Vite** - Build tool & dev server
- **Tailwind CSS** - Styling
- **ethers.js v6** - Ethereum interactions
- **Zustand** - State management
- **React Hot Toast** - Notifications
- **Lucide React** - Icons

## Features

- 🔗 **MetaMask Integration** - Connect wallet and sign transactions
- 📊 **Real-time Order Book** - Live bid/ask updates every 2 seconds
- 💱 **Place Orders** - Buy and sell MONAD with limit orders
- 📈 **Analytics Dashboard** - Performance metrics and comparisons
- 🎨 **Modern UI** - Dark theme with Tailwind CSS
- ⚡ **Fast Development** - Vite HMR for instant updates

## Getting Started

### Prerequisites

- Node.js 18+
- MetaMask browser extension
- Hardhat node running (for local development)

### Installation

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

## Project Structure

```
src/
├── components/          # React components
│   ├── Header.tsx      # Navigation and wallet connection
│   ├── OrderBook.tsx   # Order book display
│   └── TradeForm.tsx   # Order placement form
├── pages/              # Page components
│   ├── TradingPage.tsx # Main trading interface
│   └── AnalyticsPage.tsx # Performance dashboard
├── hooks/              # Custom React hooks
│   ├── useWeb3.ts      # Web3 interactions
│   └── useOrderBook.ts # Order book data
├── lib/                # Utilities and config
│   ├── contracts.ts    # Contract addresses & ABIs
│   ├── store.ts        # Zustand state management
│   └── utils.ts        # Helper functions
├── types/              # TypeScript types
│   └── index.ts
└── styles/             # CSS files
    └── globals.css     # Tailwind directives
```

## Usage

### Connect Wallet

1. Click "Connect Wallet" in the header
2. Approve the connection in MetaMask
3. Switch to localhost network (Chain ID: 31337)

### Place an Order

1. Navigate to Trading page
2. Select Buy or Sell
3. Enter price (in USDC) and amount (in MONAD)
4. Click the Buy/Sell button
5. Confirm transaction in MetaMask

### View Analytics

Navigate to the Analytics page to see:
- TPS (Transactions per second)
- Parallel execution rate
- Gas usage metrics
- Performance comparisons

## Development

### Environment Setup

The contract addresses are auto-generated from the deployment script and stored in `src/lib/contracts.ts`.

To update after redeployment:

```bash
# Redeploy contracts
cd ..
npx hardhat run scripts/deploy.js --network localhost

# Addresses are automatically updated in contracts.ts
```

### Local Development

```bash
# Terminal 1: Start Hardhat node
cd ..
npx hardhat node

# Terminal 2: Deploy contracts
npx hardhat run scripts/deploy.js --network localhost

# Terminal 3: Start frontend
cd frontend
npm run dev
```

### Testing

```bash
# Lint TypeScript
npm run lint

# Type check
npx tsc --noEmit
```

## Key Features

### Real-time Order Book

- Polls blockchain every 2 seconds
- Displays top 10 bid/ask levels
- Depth visualization with colored bars
- Spread calculation

### Order Placement

- Form validation
- Balance checking
- Transaction status notifications
- Automatic form reset after success

### Wallet Integration

- MetaMask connection
- Account switching detection
- Network switching
- Transaction signing

## Configuration

### Network Settings

Located in `src/lib/contracts.ts`:

```typescript
export const NETWORK = {
  chainId: 31337,        // Hardhat localhost
  name: 'localhost',
  rpcUrl: 'http://localhost:8545',
};
```

For Monad testnet, update these values after testnet launch.

## Troubleshooting

### MetaMask Not Detected

- Install MetaMask browser extension
- Refresh the page
- Check browser console for errors

### Transactions Failing

- Check you're on the correct network (localhost / Monad)
- Ensure sufficient balance in your wallet
- Verify contract is deployed
- Check Hardhat node is running

### Order Book Not Loading

- Ensure Hardhat node is running
- Check contract addresses in `contracts.ts`
- Verify RPC URL is correct
- Open browser console for error details

## Building for Production

```bash
npm run build
```

The build output will be in the `dist/` directory.

## License

MIT
