import { useOrderBook } from '@/hooks/useOrderBook';
import { formatPrice, formatAmount } from '@/lib/utils';
import type { OrderBookLevel } from '@/types';

export function OrderBook() {
  const { orderBook } = useOrderBook();

  if (!orderBook) {
    return (
      <div className="card p-6">
        <h2 className="text-xl font-bold mb-4">Order Book</h2>
        <div className="flex items-center justify-center h-96">
          <div className="text-gray-400">Loading order book...</div>
        </div>
      </div>
    );
  }

  const { bids, asks } = orderBook;

  return (
    <div className="card p-6">
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-xl font-bold">Order Book</h2>
        <span className="text-xs text-gray-400">
          Updated: {orderBook.lastUpdate.toLocaleTimeString()}
        </span>
      </div>

      <div className="space-y-4">
        {/* Header */}
        <div className="grid grid-cols-3 text-xs text-gray-400 font-semibold px-2">
          <div>Price (USDC)</div>
          <div className="text-right">Amount (MONAD)</div>
          <div className="text-right">Total</div>
        </div>

        {/* Asks (Sells) - Reversed order */}
        <div className="space-y-1">
          {[...asks].reverse().slice(0, 10).map((ask, index) => (
            <OrderBookRow key={`ask-${index}`} level={ask} isBid={false} />
          ))}
        </div>

        {/* Spread */}
        {bids[0] && asks[0] && (
          <div className="text-center py-2 bg-gray-800 rounded-lg">
            <span className="text-sm text-gray-400">Spread: </span>
            <span className="text-sm font-semibold text-primary">
              {formatPrice(asks[0].price - bids[0].price)} USDC
            </span>
          </div>
        )}

        {/* Bids (Buys) */}
        <div className="space-y-1">
          {bids.slice(0, 10).map((bid, index) => (
            <OrderBookRow key={`bid-${index}`} level={bid} isBid={true} />
          ))}
        </div>
      </div>
    </div>
  );
}

function OrderBookRow({
  level,
  isBid,
}: {
  level: OrderBookLevel;
  isBid: boolean;
}) {
  const maxDepth = 100; // For visualization
  const depthPercent = Math.min((level.amount / maxDepth) * 100, 100);

  return (
    <div className="relative group cursor-pointer hover:bg-gray-800 transition-colors rounded px-2 py-1">
      {/* Depth bar */}
      <div
        className={`absolute inset-0 ${
          isBid ? 'bg-buy/20' : 'bg-sell/20'
        } rounded`}
        style={{ width: `${depthPercent}%` }}
      />

      {/* Content */}
      <div className="relative grid grid-cols-3 text-sm">
        <div className={`font-semibold ${isBid ? 'text-buy' : 'text-sell'}`}>
          {formatPrice(level.price)}
        </div>
        <div className="text-right">{formatAmount(level.amount)}</div>
        <div className="text-right text-gray-400">
          {formatPrice(level.total)}
        </div>
      </div>
    </div>
  );
}
