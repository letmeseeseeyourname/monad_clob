// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IMonadCLOB
 * @notice Interface for the parallel-friendly Central Limit Order Book
 */
interface IMonadCLOB {
    // Events
    event PairCreated(bytes32 indexed pairId, address indexed token0, address indexed token1, uint256 tickSize, uint256 minOrderSize);
    event Deposit(address indexed user, address indexed token, uint256 amount);
    event Withdraw(address indexed user, address indexed token, uint256 amount);
    event OrderPlaced(uint256 indexed orderId, bytes32 indexed pairId, address indexed trader, bool isBuy, uint256 price, uint256 amount, uint32 expiry);
    event OrderCancelled(uint256 indexed orderId, address indexed trader);
    event OrderMatched(uint256 indexed buyOrderId, uint256 indexed sellOrderId, bytes32 indexed pairId, uint256 price, uint256 amount);

    // Structs
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

    struct TradingPair {
        address token0;
        address token1;
        uint256 tickSize;
        uint256 minOrderSize;
        uint256 bestBid;
        uint256 bestAsk;
        bool exists;
    }

    struct OrderBookLevel {
        uint256 price;
        uint256 totalAmount;
        uint256 orderCount;
    }

    // Core Functions
    function createPair(
        address token0,
        address token1,
        uint256 tickSize,
        uint256 minOrderSize
    ) external returns (bytes32 pairId);

    function deposit(address token, uint256 amount) external;

    function withdraw(address token, uint256 amount) external;

    function placeLimitOrder(
        bytes32 pairId,
        bool isBuy,
        uint256 price,
        uint256 amount,
        uint32 expiry
    ) external returns (uint256 orderId);

    function batchPlaceOrders(
        bytes32 pairId,
        bool[] calldata isBuy,
        uint256[] calldata prices,
        uint256[] calldata amounts,
        uint32[] calldata expiries
    ) external returns (uint256[] memory orderIds);

    function cancelOrder(uint256 orderId) external;

    function matchOrders(bytes32 pairId, uint8 maxLevels) external returns (uint256 totalMatched);

    // View Functions
    function getOrderBookDepth(bytes32 pairId, uint8 levels)
        external
        view
        returns (OrderBookLevel[] memory bids, OrderBookLevel[] memory asks);

    function getBestBid(bytes32 pairId) external view returns (uint256);

    function getBestAsk(bytes32 pairId) external view returns (uint256);

    function getOrder(uint256 orderId) external view returns (Order memory);

    function getPair(bytes32 pairId) external view returns (TradingPair memory);

    function getUserBalance(address user, address token) external view returns (uint256);

    function getPairId(address token0, address token1) external pure returns (bytes32);
}
