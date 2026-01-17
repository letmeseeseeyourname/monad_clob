import { OrderBook } from '@/components/OrderBook';
import { TradeForm } from '@/components/TradeForm';

export function TradingPage() {
  return (
    <div className="min-h-screen p-6">
      <div className="max-w-7xl mx-auto space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold text-primary">MONAD/USDC</h1>
            <p className="text-gray-400 mt-1">Parallel-friendly On-chain CLOB</p>
          </div>
        </div>

        {/* Main Trading Interface */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Order Book */}
          <div className="lg:col-span-2">
            <OrderBook />
          </div>

          {/* Trade Form */}
          <div>
            <TradeForm />
          </div>
        </div>

        {/* Info Cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <InfoCard
            title="24h Volume"
            value="$1,247,823"
            change="+12.5%"
            isPositive={true}
          />
          <InfoCard
            title="Best Bid"
            value="$0.99"
            subtitle="10.5 MONAD"
          />
          <InfoCard
            title="Best Ask"
            value="$1.01"
            subtitle="8.2 MONAD"
          />
        </div>
      </div>
    </div>
  );
}

function InfoCard({
  title,
  value,
  subtitle,
  change,
  isPositive,
}: {
  title: string;
  value: string;
  subtitle?: string;
  change?: string;
  isPositive?: boolean;
}) {
  return (
    <div className="card p-6">
      <div className="text-sm text-gray-400 mb-2">{title}</div>
      <div className="text-2xl font-bold">{value}</div>
      {subtitle && <div className="text-sm text-gray-400 mt-1">{subtitle}</div>}
      {change && (
        <div
          className={`text-sm mt-1 ${
            isPositive ? 'text-buy' : 'text-sell'
          }`}
        >
          {change}
        </div>
      )}
    </div>
  );
}
