export interface Order {
  orderId: bigint;
  trader: string;
  amount: bigint;
  price: bigint;
  timestamp: number;
  expiry: number;
  isBuy: boolean;
  status: OrderStatus;
}

export enum OrderStatus {
  Active = 0,
  Filled = 1,
  Cancelled = 2,
}

export interface OrderBookLevel {
  price: number;
  amount: number;
  total: number;
  orderCount: number;
}

export interface OrderBook {
  bids: OrderBookLevel[];
  asks: OrderBookLevel[];
  lastUpdate: Date;
}

export interface TradingPair {
  pairId: string;
  token0: string;
  token1: string;
  tickSize: bigint;
  minOrderSize: bigint;
  bestBid: bigint;
  bestAsk: bigint;
  exists: boolean;
  symbol: string;
}

export interface WalletState {
  address: string | null;
  isConnected: boolean;
  chainId: number | null;
}

export interface AnalyticsData {
  tps: number;
  parallelExecutionRate: number;
  avgGasPerOrder: number;
  totalOrders: number;
  totalVolume: number;
  activePriceLevels: number;
}
