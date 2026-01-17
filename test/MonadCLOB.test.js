const { expect } = require("chai");
const { ethers } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");

describe("MonadCLOB", function () {
  let monadCLOB;
  let token0, token1;
  let owner, trader1, trader2, trader3;
  let pairId;

  const TICK_SIZE = ethers.parseEther("0.01"); // 0.01 ETH
  const MIN_ORDER_SIZE = ethers.parseEther("1"); // 1 token
  const INITIAL_BALANCE = ethers.parseEther("10000");

  beforeEach(async function () {
    [owner, trader1, trader2, trader3] = await ethers.getSigners();

    // Deploy mock tokens
    const MockERC20 = await ethers.getContractFactory("MockERC20");
    token0 = await MockERC20.deploy("Token A", "TKA", 18);
    token1 = await MockERC20.deploy("Token B", "TKB", 18);

    // Deploy MonadCLOB
    const MonadCLOB = await ethers.getContractFactory("MonadCLOB");
    monadCLOB = await MonadCLOB.deploy();

    // Mint tokens to traders
    await token0.mint(trader1.address, INITIAL_BALANCE);
    await token0.mint(trader2.address, INITIAL_BALANCE);
    await token0.mint(trader3.address, INITIAL_BALANCE);

    await token1.mint(trader1.address, INITIAL_BALANCE);
    await token1.mint(trader2.address, INITIAL_BALANCE);
    await token1.mint(trader3.address, INITIAL_BALANCE);

    // Create trading pair
    const tx = await monadCLOB.createPair(
      await token0.getAddress(),
      await token1.getAddress(),
      TICK_SIZE,
      MIN_ORDER_SIZE
    );

    pairId = await monadCLOB.getPairId(await token0.getAddress(), await token1.getAddress());

    // Approve tokens
    await token0.connect(trader1).approve(await monadCLOB.getAddress(), ethers.MaxUint256);
    await token0.connect(trader2).approve(await monadCLOB.getAddress(), ethers.MaxUint256);
    await token0.connect(trader3).approve(await monadCLOB.getAddress(), ethers.MaxUint256);

    await token1.connect(trader1).approve(await monadCLOB.getAddress(), ethers.MaxUint256);
    await token1.connect(trader2).approve(await monadCLOB.getAddress(), ethers.MaxUint256);
    await token1.connect(trader3).approve(await monadCLOB.getAddress(), ethers.MaxUint256);
  });

  describe("Pair Creation", function () {
    it("Should create trading pair", async function () {
      const pair = await monadCLOB.getPair(pairId);
      expect(pair.exists).to.be.true;
      expect(pair.token0).to.equal(await token0.getAddress());
      expect(pair.token1).to.equal(await token1.getAddress());
      expect(pair.tickSize).to.equal(TICK_SIZE);
      expect(pair.minOrderSize).to.equal(MIN_ORDER_SIZE);
    });

    it("Should not create duplicate pair", async function () {
      await expect(
        monadCLOB.createPair(
          await token0.getAddress(),
          await token1.getAddress(),
          TICK_SIZE,
          MIN_ORDER_SIZE
        )
      ).to.be.revertedWith("Pair already exists");
    });

    it("Should not create pair with invalid parameters", async function () {
      const token2 = await (await ethers.getContractFactory("MockERC20")).deploy("Token C", "TKC", 18);
      const token3 = await (await ethers.getContractFactory("MockERC20")).deploy("Token D", "TKD", 18);

      await expect(
        monadCLOB.createPair(await token2.getAddress(), await token3.getAddress(), 0, MIN_ORDER_SIZE)
      ).to.be.revertedWith("Tick size must be > 0");

      await expect(
        monadCLOB.createPair(await token2.getAddress(), await token3.getAddress(), TICK_SIZE, 0)
      ).to.be.revertedWith("Min order size must be > 0");
    });
  });

  describe("Deposit and Withdraw", function () {
    it("Should deposit tokens", async function () {
      const depositAmount = ethers.parseEther("100");

      await monadCLOB.connect(trader1).deposit(await token0.getAddress(), depositAmount);

      const balance = await monadCLOB.getUserBalance(trader1.address, await token0.getAddress());
      expect(balance).to.equal(depositAmount);
    });

    it("Should withdraw tokens", async function () {
      const depositAmount = ethers.parseEther("100");
      const withdrawAmount = ethers.parseEther("50");

      await monadCLOB.connect(trader1).deposit(await token0.getAddress(), depositAmount);
      await monadCLOB.connect(trader1).withdraw(await token0.getAddress(), withdrawAmount);

      const balance = await monadCLOB.getUserBalance(trader1.address, await token0.getAddress());
      expect(balance).to.equal(depositAmount - withdrawAmount);
    });

    it("Should not withdraw more than balance", async function () {
      const depositAmount = ethers.parseEther("100");
      const withdrawAmount = ethers.parseEther("150");

      await monadCLOB.connect(trader1).deposit(await token0.getAddress(), depositAmount);

      await expect(
        monadCLOB.connect(trader1).withdraw(await token0.getAddress(), withdrawAmount)
      ).to.be.revertedWith("Insufficient balance");
    });
  });

  describe("Limit Orders", function () {
    beforeEach(async function () {
      // Deposit tokens for traders
      await monadCLOB.connect(trader1).deposit(await token0.getAddress(), ethers.parseEther("1000"));
      await monadCLOB.connect(trader1).deposit(await token1.getAddress(), ethers.parseEther("1000"));

      await monadCLOB.connect(trader2).deposit(await token0.getAddress(), ethers.parseEther("1000"));
      await monadCLOB.connect(trader2).deposit(await token1.getAddress(), ethers.parseEther("1000"));
    });

    it("Should place limit order", async function () {
      const price = ethers.parseEther("1.0");
      const amount = ethers.parseEther("10");

      const tx = await monadCLOB.connect(trader1).placeLimitOrder(
        pairId,
        true, // buy
        price,
        amount,
        0 // no expiry
      );

      const receipt = await tx.wait();
      const event = receipt.logs.find(log => {
        try {
          return monadCLOB.interface.parseLog(log)?.name === "OrderPlaced";
        } catch {
          return false;
        }
      });

      expect(event).to.not.be.undefined;

      const orderId = monadCLOB.interface.parseLog(event).args.orderId;
      const order = await monadCLOB.getOrder(orderId);

      expect(order.trader).to.equal(trader1.address);
      expect(order.amount).to.equal(amount);
      expect(order.price).to.equal(price);
      expect(order.isBuy).to.be.true;
      expect(order.status).to.equal(0); // STATUS_ACTIVE
    });

    it("Should update best bid/ask", async function () {
      const bidPrice = ethers.parseEther("0.99");
      const askPrice = ethers.parseEther("1.01");
      const amount = ethers.parseEther("10");

      await monadCLOB.connect(trader1).placeLimitOrder(pairId, true, bidPrice, amount, 0);
      await monadCLOB.connect(trader2).placeLimitOrder(pairId, false, askPrice, amount, 0);

      const bestBid = await monadCLOB.getBestBid(pairId);
      const bestAsk = await monadCLOB.getBestAsk(pairId);

      expect(bestBid).to.equal(bidPrice);
      expect(bestAsk).to.equal(askPrice);
    });

    it("Should track best bid/ask correctly", async function () {
      const amount = ethers.parseEther("10");

      // Place multiple buy orders
      await monadCLOB.connect(trader1).placeLimitOrder(pairId, true, ethers.parseEther("0.98"), amount, 0);
      await monadCLOB.connect(trader1).placeLimitOrder(pairId, true, ethers.parseEther("0.99"), amount, 0);
      await monadCLOB.connect(trader1).placeLimitOrder(pairId, true, ethers.parseEther("1.00"), amount, 0);

      // Place multiple sell orders
      await monadCLOB.connect(trader2).placeLimitOrder(pairId, false, ethers.parseEther("1.03"), amount, 0);
      await monadCLOB.connect(trader2).placeLimitOrder(pairId, false, ethers.parseEther("1.02"), amount, 0);
      await monadCLOB.connect(trader2).placeLimitOrder(pairId, false, ethers.parseEther("1.01"), amount, 0);

      const bestBid = await monadCLOB.getBestBid(pairId);
      const bestAsk = await monadCLOB.getBestAsk(pairId);

      expect(bestBid).to.equal(ethers.parseEther("1.00"));
      expect(bestAsk).to.equal(ethers.parseEther("1.01"));
    });

    it("Should not place order with invalid price", async function () {
      const invalidPrice = ethers.parseEther("1.005"); // Not a multiple of tick size
      const amount = ethers.parseEther("10");

      await expect(
        monadCLOB.connect(trader1).placeLimitOrder(pairId, true, invalidPrice, amount, 0)
      ).to.be.revertedWith("Invalid price");
    });

    it("Should not place order below minimum size", async function () {
      const price = ethers.parseEther("1.0");
      const amount = ethers.parseEther("0.5"); // Below MIN_ORDER_SIZE

      await expect(
        monadCLOB.connect(trader1).placeLimitOrder(pairId, true, price, amount, 0)
      ).to.be.revertedWith("Amount below minimum");
    });
  });

  describe("Cancel Orders", function () {
    let orderId;

    beforeEach(async function () {
      await monadCLOB.connect(trader1).deposit(await token1.getAddress(), ethers.parseEther("1000"));

      const tx = await monadCLOB.connect(trader1).placeLimitOrder(
        pairId,
        true,
        ethers.parseEther("1.0"),
        ethers.parseEther("10"),
        0
      );

      const receipt = await tx.wait();
      const event = receipt.logs.find(log => {
        try {
          return monadCLOB.interface.parseLog(log)?.name === "OrderPlaced";
        } catch {
          return false;
        }
      });

      orderId = monadCLOB.interface.parseLog(event).args.orderId;
    });

    it("Should cancel order", async function () {
      await monadCLOB.connect(trader1).cancelOrder(orderId);

      const order = await monadCLOB.getOrder(orderId);
      expect(order.status).to.equal(2); // STATUS_CANCELLED
    });

    it("Should refund tokens on cancel", async function () {
      const balanceBefore = await monadCLOB.getUserBalance(trader1.address, await token1.getAddress());

      await monadCLOB.connect(trader1).cancelOrder(orderId);

      const balanceAfter = await monadCLOB.getUserBalance(trader1.address, await token1.getAddress());
      expect(balanceAfter).to.be.gt(balanceBefore);
    });

    it("Should not cancel other user's order", async function () {
      await expect(
        monadCLOB.connect(trader2).cancelOrder(orderId)
      ).to.be.revertedWith("Not order owner");
    });
  });

  describe("Order Matching", function () {
    beforeEach(async function () {
      await monadCLOB.connect(trader1).deposit(await token0.getAddress(), ethers.parseEther("1000"));
      await monadCLOB.connect(trader2).deposit(await token1.getAddress(), ethers.parseEther("1000"));
    });

    it("Should match crossing orders", async function () {
      const amount = ethers.parseEther("10");

      // Place sell order at 1.0
      await monadCLOB.connect(trader1).placeLimitOrder(
        pairId,
        false, // sell
        ethers.parseEther("1.0"),
        amount,
        0
      );

      // Place buy order at 1.0 (crosses)
      await monadCLOB.connect(trader2).placeLimitOrder(
        pairId,
        true, // buy
        ethers.parseEther("1.0"),
        amount,
        0
      );

      // Match orders
      await monadCLOB.matchOrders(pairId, 5);

      // Check balances
      const buyer2Balance = await monadCLOB.getUserBalance(trader2.address, await token0.getAddress());
      const seller1Balance = await monadCLOB.getUserBalance(trader1.address, await token1.getAddress());

      expect(buyer2Balance).to.equal(amount);
      expect(seller1Balance).to.be.gt(0);
    });

    it("Should handle partial fills", async function () {
      const sellAmount = ethers.parseEther("10");
      const buyAmount = ethers.parseEther("5");

      // Place larger sell order
      const sellTx = await monadCLOB.connect(trader1).placeLimitOrder(
        pairId,
        false,
        ethers.parseEther("1.0"),
        sellAmount,
        0
      );

      const sellReceipt = await sellTx.wait();
      const sellEvent = sellReceipt.logs.find(log => {
        try {
          return monadCLOB.interface.parseLog(log)?.name === "OrderPlaced";
        } catch {
          return false;
        }
      });
      const sellOrderId = monadCLOB.interface.parseLog(sellEvent).args.orderId;

      // Place smaller buy order
      await monadCLOB.connect(trader2).placeLimitOrder(
        pairId,
        true,
        ethers.parseEther("1.0"),
        buyAmount,
        0
      );

      // Match orders
      await monadCLOB.matchOrders(pairId, 5);

      // Check sell order is partially filled
      const sellOrder = await monadCLOB.getOrder(sellOrderId);
      expect(sellOrder.amount).to.equal(sellAmount - buyAmount);
      expect(sellOrder.status).to.equal(0); // Still active
    });

    it("Should maintain price-time priority", async function () {
      const amount = ethers.parseEther("5");

      // Place two sell orders at same price
      const tx1 = await monadCLOB.connect(trader1).placeLimitOrder(
        pairId,
        false,
        ethers.parseEther("1.0"),
        amount,
        0
      );

      const receipt1 = await tx1.wait();
      const event1 = receipt1.logs.find(log => {
        try {
          return monadCLOB.interface.parseLog(log)?.name === "OrderPlaced";
        } catch {
          return false;
        }
      });
      const orderId1 = monadCLOB.interface.parseLog(event1).args.orderId;

      // Wait a bit
      await time.increase(1);

      await monadCLOB.connect(trader1).placeLimitOrder(
        pairId,
        false,
        ethers.parseEther("1.0"),
        amount,
        0
      );

      // Place buy order that matches only one
      await monadCLOB.connect(trader2).placeLimitOrder(
        pairId,
        true,
        ethers.parseEther("1.0"),
        amount,
        0
      );

      // Match orders
      await monadCLOB.matchOrders(pairId, 5);

      // First order should be filled
      const order1 = await monadCLOB.getOrder(orderId1);
      expect(order1.status).to.equal(1); // STATUS_FILLED
    });
  });

  describe("Order Book Depth", function () {
    beforeEach(async function () {
      await monadCLOB.connect(trader1).deposit(await token0.getAddress(), ethers.parseEther("1000"));
      await monadCLOB.connect(trader1).deposit(await token1.getAddress(), ethers.parseEther("1000"));
      await monadCLOB.connect(trader2).deposit(await token0.getAddress(), ethers.parseEther("1000"));
      await monadCLOB.connect(trader2).deposit(await token1.getAddress(), ethers.parseEther("1000"));
    });

    it("Should return order book depth", async function () {
      const amount = ethers.parseEther("10");

      // Place buy orders
      await monadCLOB.connect(trader1).placeLimitOrder(pairId, true, ethers.parseEther("0.98"), amount, 0);
      await monadCLOB.connect(trader1).placeLimitOrder(pairId, true, ethers.parseEther("0.99"), amount, 0);
      await monadCLOB.connect(trader1).placeLimitOrder(pairId, true, ethers.parseEther("1.00"), amount, 0);

      // Place sell orders
      await monadCLOB.connect(trader2).placeLimitOrder(pairId, false, ethers.parseEther("1.01"), amount, 0);
      await monadCLOB.connect(trader2).placeLimitOrder(pairId, false, ethers.parseEther("1.02"), amount, 0);
      await monadCLOB.connect(trader2).placeLimitOrder(pairId, false, ethers.parseEther("1.03"), amount, 0);

      const [bids, asks] = await monadCLOB.getOrderBookDepth(pairId, 10);

      expect(bids.length).to.equal(10);
      expect(asks.length).to.equal(10);

      // Check first levels
      expect(bids[0].price).to.equal(ethers.parseEther("1.00"));
      expect(asks[0].price).to.equal(ethers.parseEther("1.01"));
    });
  });

  describe("Batch Operations", function () {
    beforeEach(async function () {
      await monadCLOB.connect(trader1).deposit(await token1.getAddress(), ethers.parseEther("10000"));
    });

    it("Should place multiple orders in batch", async function () {
      const prices = [
        ethers.parseEther("0.98"),
        ethers.parseEther("0.99"),
        ethers.parseEther("1.00")
      ];
      const amounts = [
        ethers.parseEther("10"),
        ethers.parseEther("10"),
        ethers.parseEther("10")
      ];
      const isBuy = [true, true, true];
      const expiries = [0, 0, 0];

      const tx = await monadCLOB.connect(trader1).batchPlaceOrders(
        pairId,
        isBuy,
        prices,
        amounts,
        expiries
      );

      const receipt = await tx.wait();

      // Count OrderPlaced events
      const orderPlacedEvents = receipt.logs.filter(log => {
        try {
          return monadCLOB.interface.parseLog(log)?.name === "OrderPlaced";
        } catch {
          return false;
        }
      });

      expect(orderPlacedEvents.length).to.equal(3);
    });
  });

  describe("Stress Test", function () {
    it("Should process 100 concurrent orders", async function () {
      // Deposit large amounts for all traders
      await monadCLOB.connect(trader1).deposit(await token0.getAddress(), ethers.parseEther("5000"));
      await monadCLOB.connect(trader1).deposit(await token1.getAddress(), ethers.parseEther("5000"));
      await monadCLOB.connect(trader2).deposit(await token0.getAddress(), ethers.parseEther("5000"));
      await monadCLOB.connect(trader2).deposit(await token1.getAddress(), ethers.parseEther("5000"));
      await monadCLOB.connect(trader3).deposit(await token0.getAddress(), ethers.parseEther("5000"));
      await monadCLOB.connect(trader3).deposit(await token1.getAddress(), ethers.parseEther("5000"));

      const promises = [];
      const amount = ethers.parseEther("10");

      // Create 100 orders at different price levels (parallel-friendly)
      for (let i = 0; i < 100; i++) {
        const basePrice = 100 + i; // 1.00, 1.01, 1.02, etc.
        const price = ethers.parseEther((basePrice / 100).toString());
        const isBuy = i % 2 === 0;
        const trader = [trader1, trader2, trader3][i % 3];

        promises.push(
          monadCLOB.connect(trader).placeLimitOrder(pairId, isBuy, price, amount, 0)
        );
      }

      // Execute all orders (simulating parallel execution on Monad)
      const results = await Promise.all(promises);

      expect(results.length).to.equal(100);
    }).timeout(60000); // 60 second timeout for this test
  });
});
