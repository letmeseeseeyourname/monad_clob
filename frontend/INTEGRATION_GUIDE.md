# Web3 Integration Guide

## Current Status

✅ Web3 services created
✅ Contract constants auto-generated from deployment
✅ Providers set up for state management
⚠️ UI needs to be connected to providers

## Quick Integration Example

### 1. Display Real Order Book Data

Update `lib/features/trading/screens/trading_screen.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/order_book_provider.dart';

class TradingScreen extends ConsumerWidget {
  const TradingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderBookState = ref.watch(orderBookProvider);

    if (orderBookState.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (orderBookState.error != null) {
      return Center(child: Text('Error: ${orderBookState.error}'));
    }

    final orderBook = orderBookState.data;

    // Use real data from blockchain
    // orderBook.bids, orderBook.asks
  }
}
```

### 2. Test with Hardhat Accounts

For local testing, you can connect with a Hardhat test account:

```dart
// In your app, add a button to connect for testing
ElevatedButton(
  onPressed: () {
    ref.read(walletServiceProvider.notifier).connectWithPrivateKey(
      '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcaaae4d6f04d3e0dd'
    );
  },
  child: Text('Connect Test Wallet'),
)
```

## Available Test Accounts

From your Hardhat node:

```
Account #0: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
Private Key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcaaae4d6f04d3e0dd

Account #1: 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
Private Key: 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
```

## Order Book Data Flow

1. **orderBookProvider** polls blockchain every 2 seconds
2. Calls **contractService.getOrderBookDepth()**
3. Fetches from **MonadCLOB contract** at `0x5FbDB2315678afecb367f032d93F642f64180aa3`
4. Updates UI automatically via Riverpod state management

## Place Order Flow

```dart
// 1. Connect wallet
await ref.read(walletServiceProvider.notifier)
  .connectWithPrivateKey('0x...');

// 2. Get credentials
final credentials = ref.read(walletServiceProvider.notifier)
  .getCredentials('0x...');

// 3. Place order
final txHash = await ref.read(contractServiceProvider)
  .placeLimitOrder(
    credentials: credentials!,
    pairId: MONAD_USDC_PAIR_ID,
    isBuy: true,
    price: BigInt.from(1000000), // 1.0 USDC (6 decimals)
    amount: BigInt.from(10) * BigInt.from(10).pow(18), // 10 MONAD
    expiry: 0,
  );

// 4. Order appears in order book automatically
```

## Testing Checklist

- [ ] Start Hardhat node
- [ ] Deploy contracts
- [ ] Run Flutter app
- [ ] See order book fetching (check console for errors)
- [ ] Connect test wallet
- [ ] Place test order
- [ ] See order appear in book

## Troubleshooting

### "Connection refused" errors
- Check Hardhat node is running on `http://localhost:8545`
- Verify RPC_URL in `contract_constants.dart`

### "Contract not found" errors
- Redeploy contracts: `npx hardhat run scripts/deploy.js --network localhost`
- Check contract addresses match in `contract_constants.dart`

### Orders not appearing
- Check if order was mined: view Hardhat node logs
- Verify order book is polling: add debug prints in `order_book_provider.dart`

## Next Steps

1. Update `TradingScreen` to use `orderBookProvider`
2. Update `TradeFormWidget` to call `placeLimitOrder`
3. Add wallet connection UI
4. Add transaction status notifications
5. Add order history fetching
