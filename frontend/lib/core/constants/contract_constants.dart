// Auto-generated contract constants
// Generated: 2026-01-17T01:57:21.185Z
// Network: localhost

const String CLOB_CONTRACT_ADDRESS = '0x5FbDB2315678afecb367f032d93F642f64180aa3';
const String MONAD_TOKEN_ADDRESS = '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512';
const String USDC_TOKEN_ADDRESS = '0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0';
const String WETH_TOKEN_ADDRESS = '0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9';

const String MONAD_USDC_PAIR_ID = '0x2b5e27f706fb95087c0f361f4899b5825368e7e7000e02429f51e3e30c87051c';

const List<dynamic> CLOB_CONTRACT_ABI = [
  {
    "inputs": [],
    "name": "ReentrancyGuardReentrantCall",
    "type": "error"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "token",
        "type": "address"
      }
    ],
    "name": "SafeERC20FailedOperation",
    "type": "error"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "user",
        "type": "address"
      },
      {
        "indexed": true,
        "internalType": "address",
        "name": "token",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      }
    ],
    "name": "Deposit",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "uint256",
        "name": "orderId",
        "type": "uint256"
      },
      {
        "indexed": true,
        "internalType": "address",
        "name": "trader",
        "type": "address"
      }
    ],
    "name": "OrderCancelled",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "uint256",
        "name": "buyOrderId",
        "type": "uint256"
      },
      {
        "indexed": true,
        "internalType": "uint256",
        "name": "sellOrderId",
        "type": "uint256"
      },
      {
        "indexed": true,
        "internalType": "bytes32",
        "name": "pairId",
        "type": "bytes32"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "price",
        "type": "uint256"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      }
    ],
    "name": "OrderMatched",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "uint256",
        "name": "orderId",
        "type": "uint256"
      },
      {
        "indexed": true,
        "internalType": "bytes32",
        "name": "pairId",
        "type": "bytes32"
      },
      {
        "indexed": true,
        "internalType": "address",
        "name": "trader",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "bool",
        "name": "isBuy",
        "type": "bool"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "price",
        "type": "uint256"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      },
      {
        "indexed": false,
        "internalType": "uint32",
        "name": "expiry",
        "type": "uint32"
      }
    ],
    "name": "OrderPlaced",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "bytes32",
        "name": "pairId",
        "type": "bytes32"
      },
      {
        "indexed": true,
        "internalType": "address",
        "name": "token0",
        "type": "address"
      },
      {
        "indexed": true,
        "internalType": "address",
        "name": "token1",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "tickSize",
        "type": "uint256"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "minOrderSize",
        "type": "uint256"
      }
    ],
    "name": "PairCreated",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "user",
        "type": "address"
      },
      {
        "indexed": true,
        "internalType": "address",
        "name": "token",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      }
    ],
    "name": "Withdraw",
    "type": "event"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      },
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "name": "balances",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "pairId",
        "type": "bytes32"
      },
      {
        "internalType": "bool[]",
        "name": "isBuy",
        "type": "bool[]"
      },
      {
        "internalType": "uint256[]",
        "name": "prices",
        "type": "uint256[]"
      },
      {
        "internalType": "uint256[]",
        "name": "amounts",
        "type": "uint256[]"
      },
      {
        "internalType": "uint32[]",
        "name": "expiries",
        "type": "uint32[]"
      }
    ],
    "name": "batchPlaceOrders",
    "outputs": [
      {
        "internalType": "uint256[]",
        "name": "orderIds",
        "type": "uint256[]"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "",
        "type": "bytes32"
      },
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "name": "buyBook",
    "outputs": [
      {
        "internalType": "uint128",
        "name": "totalAmount",
        "type": "uint128"
      },
      {
        "internalType": "uint64",
        "name": "orderCount",
        "type": "uint64"
      },
      {
        "internalType": "uint64",
        "name": "head",
        "type": "uint64"
      },
      {
        "internalType": "uint64",
        "name": "tail",
        "type": "uint64"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "orderId",
        "type": "uint256"
      }
    ],
    "name": "cancelOrder",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "token0",
        "type": "address"
      },
      {
        "internalType": "address",
        "name": "token1",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "tickSize",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "minOrderSize",
        "type": "uint256"
      }
    ],
    "name": "createPair",
    "outputs": [
      {
        "internalType": "bytes32",
        "name": "pairId",
        "type": "bytes32"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "token",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      }
    ],
    "name": "deposit",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "pairId",
        "type": "bytes32"
      }
    ],
    "name": "getBestAsk",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "pairId",
        "type": "bytes32"
      }
    ],
    "name": "getBestBid",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "orderId",
        "type": "uint256"
      }
    ],
    "name": "getOrder",
    "outputs": [
      {
        "components": [
          {
            "internalType": "address",
            "name": "trader",
            "type": "address"
          },
          {
            "internalType": "uint96",
            "name": "amount",
            "type": "uint96"
          },
          {
            "internalType": "uint96",
            "name": "price",
            "type": "uint96"
          },
          {
            "internalType": "uint32",
            "name": "timestamp",
            "type": "uint32"
          },
          {
            "internalType": "uint32",
            "name": "expiry",
            "type": "uint32"
          },
          {
            "internalType": "bool",
            "name": "isBuy",
            "type": "bool"
          },
          {
            "internalType": "uint8",
            "name": "status",
            "type": "uint8"
          }
        ],
        "internalType": "struct IMonadCLOB.Order",
        "name": "",
        "type": "tuple"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "pairId",
        "type": "bytes32"
      },
      {
        "internalType": "uint8",
        "name": "levels",
        "type": "uint8"
      }
    ],
    "name": "getOrderBookDepth",
    "outputs": [
      {
        "components": [
          {
            "internalType": "uint256",
            "name": "price",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "totalAmount",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "orderCount",
            "type": "uint256"
          }
        ],
        "internalType": "struct IMonadCLOB.OrderBookLevel[]",
        "name": "bids",
        "type": "tuple[]"
      },
      {
        "components": [
          {
            "internalType": "uint256",
            "name": "price",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "totalAmount",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "orderCount",
            "type": "uint256"
          }
        ],
        "internalType": "struct IMonadCLOB.OrderBookLevel[]",
        "name": "asks",
        "type": "tuple[]"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "pairId",
        "type": "bytes32"
      }
    ],
    "name": "getPair",
    "outputs": [
      {
        "components": [
          {
            "internalType": "address",
            "name": "token0",
            "type": "address"
          },
          {
            "internalType": "address",
            "name": "token1",
            "type": "address"
          },
          {
            "internalType": "uint256",
            "name": "tickSize",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "minOrderSize",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "bestBid",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "bestAsk",
            "type": "uint256"
          },
          {
            "internalType": "bool",
            "name": "exists",
            "type": "bool"
          }
        ],
        "internalType": "struct IMonadCLOB.TradingPair",
        "name": "",
        "type": "tuple"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "token0",
        "type": "address"
      },
      {
        "internalType": "address",
        "name": "token1",
        "type": "address"
      }
    ],
    "name": "getPairId",
    "outputs": [
      {
        "internalType": "bytes32",
        "name": "",
        "type": "bytes32"
      }
    ],
    "stateMutability": "pure",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "user",
        "type": "address"
      },
      {
        "internalType": "address",
        "name": "token",
        "type": "address"
      }
    ],
    "name": "getUserBalance",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "pairId",
        "type": "bytes32"
      },
      {
        "internalType": "uint8",
        "name": "maxLevels",
        "type": "uint8"
      }
    ],
    "name": "matchOrders",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "totalMatched",
        "type": "uint256"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "name": "nextOrder",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "name": "orderToPair",
    "outputs": [
      {
        "internalType": "bytes32",
        "name": "",
        "type": "bytes32"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "name": "orders",
    "outputs": [
      {
        "internalType": "address",
        "name": "trader",
        "type": "address"
      },
      {
        "internalType": "uint96",
        "name": "amount",
        "type": "uint96"
      },
      {
        "internalType": "uint96",
        "name": "price",
        "type": "uint96"
      },
      {
        "internalType": "uint32",
        "name": "timestamp",
        "type": "uint32"
      },
      {
        "internalType": "uint32",
        "name": "expiry",
        "type": "uint32"
      },
      {
        "internalType": "bool",
        "name": "isBuy",
        "type": "bool"
      },
      {
        "internalType": "uint8",
        "name": "status",
        "type": "uint8"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "",
        "type": "bytes32"
      }
    ],
    "name": "pairs",
    "outputs": [
      {
        "internalType": "address",
        "name": "token0",
        "type": "address"
      },
      {
        "internalType": "address",
        "name": "token1",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "tickSize",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "minOrderSize",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "bestBid",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "bestAsk",
        "type": "uint256"
      },
      {
        "internalType": "bool",
        "name": "exists",
        "type": "bool"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "pairId",
        "type": "bytes32"
      },
      {
        "internalType": "bool",
        "name": "isBuy",
        "type": "bool"
      },
      {
        "internalType": "uint256",
        "name": "price",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      },
      {
        "internalType": "uint32",
        "name": "expiry",
        "type": "uint32"
      }
    ],
    "name": "placeLimitOrder",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "orderId",
        "type": "uint256"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "",
        "type": "bytes32"
      },
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "name": "sellBook",
    "outputs": [
      {
        "internalType": "uint128",
        "name": "totalAmount",
        "type": "uint128"
      },
      {
        "internalType": "uint64",
        "name": "orderCount",
        "type": "uint64"
      },
      {
        "internalType": "uint64",
        "name": "head",
        "type": "uint64"
      },
      {
        "internalType": "uint64",
        "name": "tail",
        "type": "uint64"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "token",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      }
    ],
    "name": "withdraw",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
];

const Map<String, dynamic> DEPLOYMENT_INFO = {
  "network": "localhost",
  "chainId": "31337",
  "deployer": "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
  "timestamp": "2026-01-17T01:57:21.185Z",
  "contracts": {
    "MonadCLOB": {
      "address": "0x5FbDB2315678afecb367f032d93F642f64180aa3",
      "abi": "artifacts/contracts/MonadCLOB.sol/MonadCLOB.json"
    },
    "MONAD": {
      "address": "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512",
      "symbol": "MONAD",
      "decimals": 18
    },
    "USDC": {
      "address": "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0",
      "symbol": "USDC",
      "decimals": 6
    },
    "WETH": {
      "address": "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9",
      "symbol": "WETH",
      "decimals": 18
    }
  },
  "pairs": {
    "MONAD/USDC": {
      "pairId": "0x2b5e27f706fb95087c0f361f4899b5825368e7e7000e02429f51e3e30c87051c",
      "token0": "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512",
      "token1": "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0",
      "tickSize": "10000",
      "minOrderSize": "1000000000000000000"
    }
  }
};
