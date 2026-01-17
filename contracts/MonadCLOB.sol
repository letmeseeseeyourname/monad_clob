// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./interfaces/IMonadCLOB.sol";

/**
 * @title MonadCLOB
 * @notice Parallel-friendly Central Limit Order Book optimized for Monad's parallel execution
 * @dev Uses independent storage slots per price level to enable parallel order processing
 */
contract MonadCLOB is IMonadCLOB, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // State variables
    uint256 private nextOrderId = 1;

    // Mappings for parallel-friendly storage
    mapping(bytes32 => TradingPair) public pairs;
    mapping(bytes32 => mapping(uint256 => PriceLevel)) public buyBook;
    mapping(bytes32 => mapping(uint256 => PriceLevel)) public sellBook;
    mapping(uint256 => Order) public orders;
    mapping(uint256 => uint256) public nextOrder; // Linked list for orders
    mapping(uint256 => bytes32) public orderToPair; // orderId => pairId
    mapping(address => mapping(address => uint256)) public balances; // user => token => balance

    // Constants
    uint256 private constant MAX_EXPIRY = 365 days;
    uint8 private constant STATUS_ACTIVE = 0;
    uint8 private constant STATUS_FILLED = 1;
    uint8 private constant STATUS_CANCELLED = 2;

    /**
     * @notice Create a new trading pair
     * @param token0 First token address
     * @param token1 Second token address
     * @param tickSize Minimum price increment
     * @param minOrderSize Minimum order size
     * @return pairId The unique identifier for the trading pair
     */
    function createPair(
        address token0,
        address token1,
        uint256 tickSize,
        uint256 minOrderSize
    ) external returns (bytes32 pairId) {
        require(token0 != address(0) && token1 != address(0), "Invalid token addresses");
        require(token0 != token1, "Tokens must be different");
        require(tickSize > 0, "Tick size must be > 0");
        require(minOrderSize > 0, "Min order size must be > 0");

        pairId = getPairId(token0, token1);
        require(!pairs[pairId].exists, "Pair already exists");

        pairs[pairId] = TradingPair({
            token0: token0,
            token1: token1,
            tickSize: tickSize,
            minOrderSize: minOrderSize,
            bestBid: 0,
            bestAsk: type(uint256).max,
            exists: true
        });

        emit PairCreated(pairId, token0, token1, tickSize, minOrderSize);
    }

    /**
     * @notice Deposit tokens into the contract
     * @param token Token address to deposit
     * @param amount Amount to deposit
     */
    function deposit(address token, uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be > 0");

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        balances[msg.sender][token] += amount;

        emit Deposit(msg.sender, token, amount);
    }

    /**
     * @notice Withdraw tokens from the contract
     * @param token Token address to withdraw
     * @param amount Amount to withdraw
     */
    function withdraw(address token, uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be > 0");
        require(balances[msg.sender][token] >= amount, "Insufficient balance");

        balances[msg.sender][token] -= amount;
        IERC20(token).safeTransfer(msg.sender, amount);

        emit Withdraw(msg.sender, token, amount);
    }

    /**
     * @notice Place a limit order
     * @param pairId Trading pair identifier
     * @param isBuy True for buy order, false for sell order
     * @param price Order price
     * @param amount Order amount
     * @param expiry Expiration timestamp (0 for no expiry)
     * @return orderId The unique identifier for the order
     */
    function placeLimitOrder(
        bytes32 pairId,
        bool isBuy,
        uint256 price,
        uint256 amount,
        uint32 expiry
    ) external returns (uint256 orderId) {
        return _placeLimitOrderInternal(pairId, isBuy, price, amount, expiry, msg.sender);
    }

    /**
     * @notice Place multiple limit orders in batch
     * @param pairId Trading pair identifier
     * @param isBuy Array of order types (true for buy, false for sell)
     * @param prices Array of order prices
     * @param amounts Array of order amounts
     * @param expiries Array of expiration timestamps
     * @return orderIds Array of created order IDs
     */
    function batchPlaceOrders(
        bytes32 pairId,
        bool[] calldata isBuy,
        uint256[] calldata prices,
        uint256[] calldata amounts,
        uint32[] calldata expiries
    ) external returns (uint256[] memory orderIds) {
        require(
            isBuy.length == prices.length &&
            prices.length == amounts.length &&
            amounts.length == expiries.length,
            "Array length mismatch"
        );
        require(isBuy.length > 0 && isBuy.length <= 100, "Invalid batch size");

        orderIds = new uint256[](isBuy.length);

        for (uint256 i = 0; i < isBuy.length; i++) {
            orderIds[i] = _placeLimitOrderInternal(
                pairId,
                isBuy[i],
                prices[i],
                amounts[i],
                expiries[i],
                msg.sender
            );
        }
    }

    function _placeLimitOrderInternal(
        bytes32 pairId,
        bool isBuy,
        uint256 price,
        uint256 amount,
        uint32 expiry,
        address trader
    ) private returns (uint256 orderId) {
        TradingPair storage pair = pairs[pairId];
        require(pair.exists, "Pair does not exist");
        require(price > 0 && price % pair.tickSize == 0, "Invalid price");
        require(amount >= pair.minOrderSize, "Amount below minimum");
        require(expiry == 0 || expiry > block.timestamp, "Invalid expiry");
        require(expiry == 0 || expiry <= block.timestamp + MAX_EXPIRY, "Expiry too far");

        // Check balance
        address tokenToLock = isBuy ? pair.token1 : pair.token0;
        uint256 requiredBalance = isBuy ? (price * amount) / 1e18 : amount;
        require(balances[trader][tokenToLock] >= requiredBalance, "Insufficient balance");

        // Lock funds
        balances[trader][tokenToLock] -= requiredBalance;

        // Create order
        orderId = nextOrderId++;
        orders[orderId] = Order({
            trader: trader,
            amount: uint96(amount),
            price: uint96(price),
            timestamp: uint32(block.timestamp),
            expiry: expiry,
            isBuy: isBuy,
            status: STATUS_ACTIVE
        });

        // Store pair mapping
        orderToPair[orderId] = pairId;

        // Add to order book
        _addToOrderBook(pairId, orderId, isBuy, price, amount);

        // Update best bid/ask
        _updateBestPrices(pairId, isBuy, price);

        emit OrderPlaced(orderId, pairId, trader, isBuy, price, amount, expiry);
    }

    /**
     * @notice Cancel an active order
     * @param orderId Order ID to cancel
     */
    function cancelOrder(uint256 orderId) external {
        Order storage order = orders[orderId];
        require(order.trader == msg.sender, "Not order owner");
        require(order.status == STATUS_ACTIVE, "Order not active");

        // Mark as cancelled (lazy cleanup)
        order.status = STATUS_CANCELLED;

        // Refund locked funds
        bytes32 pairId = _findPairIdForOrder(orderId);
        TradingPair storage pair = pairs[pairId];

        address tokenToRefund = order.isBuy ? pair.token1 : pair.token0;
        uint256 refundAmount = order.isBuy ?
            (uint256(order.price) * uint256(order.amount)) / 1e18 :
            uint256(order.amount);

        balances[msg.sender][tokenToRefund] += refundAmount;

        // Remove from order book
        _removeFromOrderBook(pairId, orderId, order.isBuy, order.price, order.amount);

        emit OrderCancelled(orderId, msg.sender);
    }

    /**
     * @notice Match crossing orders with depth limit
     * @param pairId Trading pair identifier
     * @param maxLevels Maximum price levels to process (prevents unbounded gas)
     * @return totalMatched Total amount matched
     */
    function matchOrders(bytes32 pairId, uint8 maxLevels) external returns (uint256 totalMatched) {
        require(maxLevels > 0 && maxLevels <= 10, "Invalid max levels");
        TradingPair storage pair = pairs[pairId];
        require(pair.exists, "Pair does not exist");

        uint8 levelsProcessed = 0;

        while (levelsProcessed < maxLevels && pair.bestBid > 0 && pair.bestAsk < type(uint256).max) {
            // Check if orders cross
            if (pair.bestBid < pair.bestAsk) break;

            uint256 matchPrice = pair.bestAsk; // Match at ask price
            PriceLevel storage buyLevel = buyBook[pairId][pair.bestBid];
            PriceLevel storage sellLevel = sellBook[pairId][pair.bestAsk];

            if (buyLevel.orderCount == 0 || sellLevel.orderCount == 0) break;

            // Match orders at this price level
            uint256 matched = _matchAtPriceLevel(pairId, pair.bestBid, pair.bestAsk, matchPrice);
            totalMatched += matched;

            if (matched == 0) break;

            // Update best prices
            _updateBestBidFromBook(pairId);
            _updateBestAskFromBook(pairId);

            levelsProcessed++;
        }
    }

    /**
     * @notice Get order book depth
     * @param pairId Trading pair identifier
     * @param levels Number of price levels to return
     * @return bids Array of bid levels
     * @return asks Array of ask levels
     */
    function getOrderBookDepth(bytes32 pairId, uint8 levels)
        external
        view
        returns (OrderBookLevel[] memory bids, OrderBookLevel[] memory asks)
    {
        require(pairs[pairId].exists, "Pair does not exist");
        require(levels > 0 && levels <= 50, "Invalid levels");

        bids = new OrderBookLevel[](levels);
        asks = new OrderBookLevel[](levels);

        // Get bid levels (descending from best bid)
        uint256 currentPrice = pairs[pairId].bestBid;
        for (uint8 i = 0; i < levels && currentPrice > 0; i++) {
            PriceLevel storage level = buyBook[pairId][currentPrice];
            if (level.orderCount > 0) {
                bids[i] = OrderBookLevel({
                    price: currentPrice,
                    totalAmount: level.totalAmount,
                    orderCount: level.orderCount
                });
            }
            currentPrice = _getNextLowerPrice(pairId, currentPrice);
        }

        // Get ask levels (ascending from best ask)
        currentPrice = pairs[pairId].bestAsk;
        for (uint8 i = 0; i < levels && currentPrice < type(uint256).max; i++) {
            PriceLevel storage level = sellBook[pairId][currentPrice];
            if (level.orderCount > 0) {
                asks[i] = OrderBookLevel({
                    price: currentPrice,
                    totalAmount: level.totalAmount,
                    orderCount: level.orderCount
                });
            }
            currentPrice = _getNextHigherPrice(pairId, currentPrice);
        }
    }

    /**
     * @notice Get best bid price
     * @param pairId Trading pair identifier
     * @return Best bid price
     */
    function getBestBid(bytes32 pairId) external view returns (uint256) {
        return pairs[pairId].bestBid;
    }

    /**
     * @notice Get best ask price
     * @param pairId Trading pair identifier
     * @return Best ask price
     */
    function getBestAsk(bytes32 pairId) external view returns (uint256) {
        return pairs[pairId].bestAsk;
    }

    /**
     * @notice Get order details
     * @param orderId Order ID
     * @return Order details
     */
    function getOrder(uint256 orderId) external view returns (Order memory) {
        return orders[orderId];
    }

    /**
     * @notice Get trading pair details
     * @param pairId Pair ID
     * @return Trading pair details
     */
    function getPair(bytes32 pairId) external view returns (TradingPair memory) {
        return pairs[pairId];
    }

    /**
     * @notice Get user balance for a token
     * @param user User address
     * @param token Token address
     * @return User's balance
     */
    function getUserBalance(address user, address token) external view returns (uint256) {
        return balances[user][token];
    }

    /**
     * @notice Calculate pair ID from token addresses
     * @param token0 First token
     * @param token1 Second token
     * @return pairId Unique pair identifier
     */
    function getPairId(address token0, address token1) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(token0, token1));
    }

    // Internal functions

    function _addToOrderBook(
        bytes32 pairId,
        uint256 orderId,
        bool isBuy,
        uint256 price,
        uint256 amount
    ) private {
        mapping(uint256 => PriceLevel) storage book = isBuy ? buyBook[pairId] : sellBook[pairId];
        PriceLevel storage level = book[price];

        if (level.orderCount == 0) {
            // First order at this price level
            level.head = uint64(orderId);
            level.tail = uint64(orderId);
        } else {
            // Append to tail (FIFO)
            nextOrder[level.tail] = orderId;
            level.tail = uint64(orderId);
        }

        level.totalAmount += uint128(amount);
        level.orderCount++;
    }

    function _removeFromOrderBook(
        bytes32 pairId,
        uint256 /* orderId */,
        bool isBuy,
        uint256 price,
        uint256 amount
    ) private {
        mapping(uint256 => PriceLevel) storage book = isBuy ? buyBook[pairId] : sellBook[pairId];
        PriceLevel storage level = book[price];

        if (level.orderCount > 0) {
            level.totalAmount -= uint128(amount);
            level.orderCount--;
        }
    }

    function _updateBestPrices(bytes32 pairId, bool isBuy, uint256 price) private {
        TradingPair storage pair = pairs[pairId];

        if (isBuy) {
            if (price > pair.bestBid) {
                pair.bestBid = price;
            }
        } else {
            if (price < pair.bestAsk) {
                pair.bestAsk = price;
            }
        }
    }

    function _matchAtPriceLevel(
        bytes32 pairId,
        uint256 bidPrice,
        uint256 askPrice,
        uint256 matchPrice
    ) private returns (uint256 totalMatched) {
        PriceLevel storage buyLevel = buyBook[pairId][bidPrice];
        PriceLevel storage sellLevel = sellBook[pairId][askPrice];

        uint256 buyOrderId = buyLevel.head;
        uint256 sellOrderId = sellLevel.head;

        while (buyOrderId != 0 && sellOrderId != 0 && totalMatched < 10) {
            Order storage buyOrder = orders[buyOrderId];
            Order storage sellOrder = orders[sellOrderId];

            // Skip expired or cancelled orders
            if (_isOrderInvalid(buyOrder)) {
                buyOrderId = nextOrder[buyOrderId];
                continue;
            }
            if (_isOrderInvalid(sellOrder)) {
                sellOrderId = nextOrder[sellOrderId];
                continue;
            }

            // Match orders
            uint256 matchAmount = buyOrder.amount < sellOrder.amount ?
                buyOrder.amount : sellOrder.amount;

            _executeMatch(pairId, buyOrderId, sellOrderId, matchPrice, matchAmount);

            totalMatched += matchAmount;

            // Move to next orders if filled
            if (buyOrder.status == STATUS_FILLED) {
                buyOrderId = nextOrder[buyOrderId];
            }
            if (sellOrder.status == STATUS_FILLED) {
                sellOrderId = nextOrder[sellOrderId];
            }
        }

        // Update level heads
        buyLevel.head = uint64(buyOrderId);
        sellLevel.head = uint64(sellOrderId);
    }

    function _executeMatch(
        bytes32 pairId,
        uint256 buyOrderId,
        uint256 sellOrderId,
        uint256 price,
        uint256 amount
    ) private {
        Order storage buyOrder = orders[buyOrderId];
        Order storage sellOrder = orders[sellOrderId];
        TradingPair storage pair = pairs[pairId];

        // Update order amounts
        buyOrder.amount -= uint96(amount);
        sellOrder.amount -= uint96(amount);

        // Mark as filled if amount is 0
        if (buyOrder.amount == 0) buyOrder.status = STATUS_FILLED;
        if (sellOrder.amount == 0) sellOrder.status = STATUS_FILLED;

        // Transfer tokens
        uint256 token1Amount = (price * amount) / 1e18;

        // Buyer receives token0, pays token1
        balances[buyOrder.trader][pair.token0] += amount;

        // Seller receives token1, already paid token0
        balances[sellOrder.trader][pair.token1] += token1Amount;

        // Refund excess to buyer if any
        uint256 buyerLocked = (uint256(buyOrder.price) * amount) / 1e18;
        if (buyerLocked > token1Amount) {
            balances[buyOrder.trader][pair.token1] += (buyerLocked - token1Amount);
        }

        // Update order book levels
        PriceLevel storage buyLevel = buyBook[pairId][buyOrder.price];
        PriceLevel storage sellLevel = sellBook[pairId][sellOrder.price];
        buyLevel.totalAmount -= uint128(amount);
        sellLevel.totalAmount -= uint128(amount);

        emit OrderMatched(buyOrderId, sellOrderId, pairId, price, amount);
    }

    function _isOrderInvalid(Order storage order) private view returns (bool) {
        return order.status != STATUS_ACTIVE ||
               (order.expiry > 0 && order.expiry < block.timestamp);
    }

    function _updateBestBidFromBook(bytes32 pairId) private {
        TradingPair storage pair = pairs[pairId];
        uint256 currentPrice = pair.bestBid;

        // Find next best bid with active orders
        while (currentPrice > 0) {
            if (buyBook[pairId][currentPrice].orderCount > 0) {
                pair.bestBid = currentPrice;
                return;
            }
            currentPrice = _getNextLowerPrice(pairId, currentPrice);
        }

        pair.bestBid = 0;
    }

    function _updateBestAskFromBook(bytes32 pairId) private {
        TradingPair storage pair = pairs[pairId];
        uint256 currentPrice = pair.bestAsk;

        // Find next best ask with active orders
        while (currentPrice < type(uint256).max) {
            if (sellBook[pairId][currentPrice].orderCount > 0) {
                pair.bestAsk = currentPrice;
                return;
            }
            currentPrice = _getNextHigherPrice(pairId, currentPrice);
        }

        pair.bestAsk = type(uint256).max;
    }

    function _getNextLowerPrice(bytes32 pairId, uint256 currentPrice) private view returns (uint256) {
        uint256 tickSize = pairs[pairId].tickSize;
        return currentPrice > tickSize ? currentPrice - tickSize : 0;
    }

    function _getNextHigherPrice(bytes32 pairId, uint256 currentPrice) private view returns (uint256) {
        uint256 tickSize = pairs[pairId].tickSize;
        uint256 nextPrice = currentPrice + tickSize;
        return nextPrice > currentPrice ? nextPrice : type(uint256).max;
    }

    function _findPairIdForOrder(uint256 orderId) private view returns (bytes32) {
        return orderToPair[orderId];
    }
}
