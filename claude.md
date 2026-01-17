# MonadCLOB Project Brief for Claude Code

## 🎯 Project Overview

Build **MonadCLOB** - a parallel-friendly on-chain Central Limit Order Book (CLOB) DEX optimized for Monad's parallel execution model.

**Core Innovation**: Prove that high-frequency on-chain CLOB is viable on EVM through smart storage architecture that enables parallel order processing.

---

## 📋 Project Specifications

### Technology Stack
- **Smart Contracts**: Solidity 0.8.20, Hardhat, OpenZeppelin
- **Frontend**: Flutter Web (web3dart, riverpod, fl_chart)
- **Blockchain**: Monad Testnet (EVM-compatible with parallel execution)
- **Testing**: Hardhat, Foundry

### Key Requirements

**Smart Contract Layer**:
1. ✅ Parallel-friendly order book storage (`mapping(pair => mapping(price => OrderQueue))`)
2. ✅ Limit order placement/cancellation
3. ✅ On-chain matching engine with depth limits (max 5 price levels per tx)
4. ✅ Batch operations for gas optimization
5. ✅ Event-driven architecture for frontend updates

**Frontend Layer**:
1. ✅ Real-time order book visualization
2. ✅ Trading interface (place/cancel orders)
3. ✅ Performance analytics dashboard (TPS, parallel execution rate, conflicts)
4. ✅ Web3 wallet integration (MetaMask)
5. ✅ Live order updates via WebSocket/polling

**Performance Targets**:
- 50-100 TPS (vs 1-2 TPS on traditional EVM)
- 80%+ parallel execution rate
- <1 second order confirmation
- ~150k gas per order

---

## 🗂️ Project Structure

```
monad-clob/
├── contracts/                    # Solidity smart contracts
│   ├── MonadCLOB.sol            # Main order book contract
│   ├── MatchingEngine.sol       # Matching logic (optional separation)
│   ├── interfaces/
│   │   └── IMonadCLOB.sol
│   └── mocks/
│       ├── MockERC20.sol
│       └── MockWETH.sol
├── scripts/                      # Deployment & testing scripts
│   ├── deploy.js
│   ├── create-pair.js
│   └── stress-test.js
├── test/                         # Smart contract tests
│   ├── MonadCLOB.test.js
│   ├── Matching.test.js
│   └── ParallelExecution.test.js
├── frontend/                     # Flutter web application
│   ├── lib/
│   │   ├── main.dart
│   │   ├── core/
│   │   │   ├── web3/
│   │   │   │   ├── contract_service.dart
│   │   │   │   ├── wallet_service.dart
│   │   │   │   └── web3_provider.dart
│   │   │   ├── models/
│   │   │   │   ├── order.dart
│   │   │   │   ├── order_book.dart
│   │   │   │   └── trading_pair.dart
│   │   │   └── constants/
│   │   │       └── contract_abis.dart
│   │   ├── features/
│   │   │   ├── trading/
│   │   │   │   ├── screens/
│   │   │   │   │   └── trading_screen.dart
│   │   │   │   ├── widgets/
│   │   │   │   │   ├── order_book_widget.dart
│   │   │   │   │   ├── trade_form_widget.dart
│   │   │   │   │   ├── price_chart_widget.dart
│   │   │   │   │   └── order_history_widget.dart
│   │   │   │   └── providers/
│   │   │   │       ├── order_book_provider.dart
│   │   │   │       └── trading_provider.dart
│   │   │   └── analytics/
│   │   │       ├── screens/
│   │   │       │   └── analytics_screen.dart
│   │   │       └── widgets/
│   │   │           ├── performance_chart.dart
│   │   │           └── stats_dashboard.dart
│   │   └── shared/
│   │       └── widgets/
│   │           ├── wallet_button.dart
│   │           └── loading_indicator.dart
│   ├── pubspec.yaml
│   └── web/
│       └── index.html
├── hardhat.config.js
├── package.json
└── README.md
```

---

## 🔧 Implementation Phases

### Phase 1: Smart Contract Core (Priority 1)

**File: `contracts/MonadCLOB.sol`**

Requirements:
```solidity
// Core data structures
struct Order {
    address trader;
    uint96 amount;
    uint96 price;
    uint32 timestamp;
    uint32 expiry;
    bool isBuy;
    uint8 status; // 0=active, 1=filled, 2=cancelled
}

struct PriceLevel {
    uint128 totalAmount;
    uint64 orderCount;
    uint64 head;  // First order ID (linked list)
    uint64 tail;  // Last order ID
}

// Key storage mappings
mapping(bytes32 => mapping(uint256 => PriceLevel)) public buyBook;
mapping(bytes32 => mapping(uint256 => PriceLevel)) public sellBook;
mapping(uint256 => Order) public orders;
mapping(uint256 => uint256) public nextOrder; // Linked list
```

**Must implement**:
1. `createPair()` - Initialize trading pair
2. `deposit()` / `withdraw()` - User balance management
3. `placeLimitOrder()` - Add order to specific price level
4. `cancelOrder()` - Remove order (optimistic-execution friendly)
5. `matchOrders()` - Match crossing orders (limit depth to 5 levels)
6. `getOrderBookDepth()` - View function for frontend
7. `batchPlaceOrders()` - Gas optimization

**Critical design notes**:
- Different price levels = different storage slots = parallel execution
- Use linked lists for FIFO ordering within price levels
- Lazy cleanup: mark orders as cancelled, skip during matching
- Emit events for every state change (OrderPlaced, OrderMatched, OrderCancelled)

**File: `test/MonadCLOB.test.js`**

Test cases:
```javascript
describe("MonadCLOB", function() {
  it("Should create trading pair");
  it("Should place limit order");
  it("Should cancel order");
  it("Should match crossing orders");
  it("Should handle partial fills");
  it("Should maintain price-time priority");
  it("Should process 100 concurrent orders"); // Stress test
  it("Should track best bid/ask correctly");
});
```

---

### Phase 2: Matching Engine Optimization (Priority 2)

**File: `contracts/MatchingEngine.sol`** (or keep in MonadCLOB.sol)

Implement advanced matching:
```solidity
function matchWithDepthLimit(
    bytes32 pairId,
    uint8 maxLevels
) external returns (uint256 totalMatched);

// For parallel testing
function parallelMatch(
    bytes32 pairId,
    uint256 priceRangeStart,
    uint256 priceRangeEnd
) external returns (uint256 matched);
```

Gas optimizations:
- Storage packing (Order struct = 32 bytes = 1 slot)
- Batch cancellation
- Reuse storage slots where possible

---

### Phase 3: Deployment Scripts (Priority 3)

**File: `scripts/deploy.js`**
```javascript
async function main() {
  // 1. Deploy MonadCLOB
  // 2. Deploy mock tokens (MONAD, USDC)
  // 3. Create MONAD/USDC pair
  // 4. Fund test accounts
  // 5. Save deployment info to frontend/lib/core/constants/
}
```

**File: `scripts/stress-test.js`**
```javascript
// Submit 100 orders to different price levels simultaneously
// Measure: TPS, gas consumption, success rate
// Log results for analytics dashboard
```

**File: `hardhat.config.js`**
```javascript
module.exports = {
  solidity: "0.8.20",
  networks: {
    monadTestnet: {
      url: "https://monad-testnet-rpc.example.com",
      chainId: 41454,
      accounts: [PRIVATE_KEY]
    }
  }
};
```

---

### Phase 4: Frontend Core (Priority 4)

**File: `frontend/lib/core/web3/contract_service.dart`**

Must implement:
```dart
class ContractService {
  // Initialize web3 client
  Future<void> initialize();
  
  // Contract calls
  Future<String> placeLimitOrder({...});
  Future<void> cancelOrder(BigInt orderId);
  
  // View functions
  Future<OrderBookData> getOrderBookDepth(String pairId, int levels);
  Future<BigInt> getBestBid(String pairId);
  Future<BigInt> getBestAsk(String pairId);
  
  // Event listeners
  Stream<OrderEvent> listenToOrderEvents();
  Stream<MatchEvent> listenToMatchEvents();
}
```

**File: `frontend/lib/core/models/order_book.dart`**
```dart
class OrderBookLevel {
  final double price;
  final double amount;
  final int orderCount;
}

class OrderBookData {
  final List<OrderBookLevel> bids;
  final List<OrderBookLevel> asks;
  final double spread;
  final DateTime lastUpdate;
}
```

---

### Phase 5: Trading UI (Priority 5)

**File: `frontend/lib/features/trading/screens/trading_screen.dart`**

Layout:
```
┌─────────────────────────────────────────┐
│  Header: MONAD/USDC | Wallet Connect    │
├──────────────┬────────────┬─────────────┤
│              │            │             │
│  Order Book  │  Chart     │  Trade Form │
│  (Real-time) │  (Price)   │  (Buy/Sell) │
│              │            │             │
├──────────────┴────────────┴─────────────┤
│  Order History (User's active orders)   │
└─────────────────────────────────────────┘
```

**File: `frontend/lib/features/trading/widgets/order_book_widget.dart`**

Requirements:
- Display 10 bid levels + 10 ask levels
- Real-time updates (poll every 2 seconds + event-driven)
- Depth visualization (horizontal bars)
- Click price to auto-fill trade form
- Highlight spread

**File: `frontend/lib/features/trading/widgets/trade_form_widget.dart`**

Requirements:
- Buy/Sell toggle
- Price input (with tick validation)
- Amount input
- Total calculation
- Balance display
- Submit button (disabled if insufficient balance)
- Loading state during tx submission

---

### Phase 6: Analytics Dashboard (Priority 6)

**File: `frontend/lib/features/analytics/screens/analytics_screen.dart`**

Display metrics:
```dart
- TPS (transactions per second)
- Parallel execution rate (%)
- Conflict rate (%)
- Average gas per order
- Total orders placed
- Total volume traded
- Active price levels
```

**File: `frontend/lib/features/analytics/widgets/performance_chart.dart`**

Use `fl_chart` to show:
- TPS over time (line chart)
- Order distribution by price (bar chart)
- Parallel vs serial execution (pie chart)

---

## 🎨 Design Specifications

### Color Scheme
```dart
// Dark theme
backgroundColor: Colors.grey[900]
cardBackground: Colors.grey[800]
textPrimary: Colors.white
textSecondary: Colors.white70
buyColor: Colors.green
sellColor: Colors.red
accentColor: Colors.amber
borderColor: Colors.grey[700]
```

### Typography
```dart
headerTextStyle: TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  color: Colors.white,
)

bodyTextStyle: TextStyle(
  fontSize: 14,
  color: Colors.white70,
)

priceTextStyle: TextStyle(
  fontFamily: 'monospace',
  fontSize: 14,
  fontWeight: FontWeight.bold,
)
```

---

## 🧪 Testing Strategy

### Smart Contract Tests
```bash
# Unit tests
npx hardhat test

# Coverage
npx hardhat coverage

# Gas report
REPORT_GAS=true npx hardhat test

# Stress test
npx hardhat run scripts/stress-test.js --network monadTestnet
```

### Frontend Tests
```bash
cd frontend

# Widget tests
flutter test

# Integration tests
flutter drive --target=test_driver/app.dart

# Build for web
flutter build web
```

---

## 📊 Success Metrics

**For Hackathon Demo**:
1. ✅ Successfully process 100 concurrent orders
2. ✅ Achieve 50+ TPS on Monad testnet
3. ✅ Demonstrate 80%+ parallel execution rate
4. ✅ Show <1s order confirmation
5. ✅ Live working demo with real-time updates
6. ✅ Clean, professional UI
7. ✅ Open-source code + documentation

**Performance Comparison**:
```
Traditional EVM CLOB:
- TPS: 1-2
- Gas: 250k per order
- Latency: 12s+

MonadCLOB (target):
- TPS: 50-100
- Gas: 150k per order
- Latency: <1s
```

---

## 🚀 Development Workflow

### Initial Setup
```bash
# 1. Initialize Hardhat project
mkdir monad-clob && cd monad-clob
npm init -y
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox
npx hardhat

# 2. Install dependencies
npm install @openzeppelin/contracts dotenv

# 3. Create Flutter project
flutter create frontend --platforms web
cd frontend
flutter pub add web3dart http riverpod fl_chart
```

### Daily Development Loop
```bash
# Terminal 1: Smart contract development
npx hardhat compile
npx hardhat test
npx hardhat node  # Local testnet

# Terminal 2: Frontend development
cd frontend
flutter run -d chrome

# Terminal 3: Deploy to Monad testnet
npx hardhat run scripts/deploy.js --network monadTestnet
```

---

## 🎯 Critical Implementation Notes

### For Smart Contracts:
1. **Storage Optimization**: Pack Order struct into 32 bytes (1 storage slot)
2. **Parallel Safety**: Each price level is independent - no shared locks
3. **Gas Efficiency**: Use `unchecked` blocks where overflow is impossible
4. **Event Emission**: Emit events BEFORE state changes for MEV resistance
5. **Reentrancy**: Use ReentrancyGuard on deposit/withdraw

### For Frontend:
1. **State Management**: Use Riverpod for reactive state
2. **Web3 Connection**: Handle MetaMask connection errors gracefully
3. **Real-time Updates**: Combine event listeners + polling (2s interval)
4. **Optimistic UI**: Show order immediately, update on confirmation
5. **Error Handling**: Display user-friendly error messages

### For Testing:
1. **Concurrency Test**: Submit 100 orders in parallel, verify no conflicts
2. **Matching Test**: Verify FIFO within price levels
3. **Gas Benchmark**: Compare batch vs individual operations
4. **Edge Cases**: Test expired orders, cancelled orders, partial fills

---

## 📝 Documentation Requirements

### README.md
```markdown
# MonadCLOB

Parallel-friendly on-chain CLOB DEX for Monad

## Architecture
[Diagram showing storage layout]

## Performance
[Comparison charts]

## Usage
[Code examples]

## Deployment
[Step-by-step guide]
```

### ARCHITECTURE.md
- Storage layout explanation
- Parallel execution model
- Matching algorithm details
- Gas optimization techniques

---

## 🔗 External References

### Monad Documentation
- RPC: `https://monad-testnet-rpc.example.com`
- Chain ID: `41454`
- Block Explorer: `https://explorer.monad.xyz`

### Contract ABIs
- Save to `frontend/lib/core/constants/contract_abis.dart` after deployment

---

## ⚡ Quick Start Commands

```bash
# Deploy contracts
npx hardhat run scripts/deploy.js --network monadTestnet

# Run stress test
npx hardhat run scripts/stress-test.js --network monadTestnet

# Start frontend
cd frontend && flutter run -d chrome

# Run all tests
npm test && cd frontend && flutter test
```

---

## 🎬 Demo Script for Hackathon

1. **Show Problem** (30 seconds)
   - Traditional CLOB on Ethereum: 1-2 TPS
   - All orders compete for same storage

2. **Explain Solution** (1 minute)
   - Monad's parallel execution
   - Storage architecture: different prices = different slots
   - Show code snippet of mapping structure

3. **Live Demo** (2 minutes)
   - Connect wallet
   - Place 10 buy orders at different prices simultaneously
   - Show real-time order book updates
   - Execute match, show instant settlement
   - Display analytics: TPS, parallel rate

4. **Performance Metrics** (30 seconds)
   - Show comparison chart: Traditional vs MonadCLOB
   - Highlight 50x improvement

5. **Open Source** (30 seconds)
   - GitHub repo link
   - Architecture documentation
   - Invite contributions

---

## 🛠️ Troubleshooting Guide

### Common Issues

**"Transaction reverted"**
- Check user balance
- Verify price is multiple of tickSize
- Check order amount > minOrderSize

**"Frontend not updating"**
- Verify WebSocket connection
- Check contract address in constants
- Ensure events are being emitted

**"Gas estimation failed"**
- Matching depth too high
- Too many concurrent operations
- Insufficient gas limit

---

## ✅ Pre-Deployment Checklist

- [ ] All tests passing
- [ ] Gas optimizations applied
- [ ] Events emitted correctly
- [ ] Frontend connects to testnet
- [ ] Wallet integration working
- [ ] Analytics dashboard populated
- [ ] README.md complete
- [ ] Demo video recorded
- [ ] GitHub repo public

---

**Start with Phase 1 (Smart Contracts) and work sequentially. Each phase builds on the previous one. Good luck! 🚀**