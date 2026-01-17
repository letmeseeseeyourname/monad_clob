import { BarChart3, TrendingUp, Zap, Activity } from 'lucide-react';

export function AnalyticsPage() {
  return (
    <div className="min-h-screen p-6">
      <div className="max-w-7xl mx-auto space-y-6">
        {/* Header */}
        <div>
          <h1 className="text-3xl font-bold">Performance Analytics</h1>
          <p className="text-gray-400 mt-1">MonadCLOB vs Traditional CLOB</p>
        </div>

        {/* Key Metrics */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <MetricCard
            icon={<Activity className="w-6 h-6" />}
            title="TPS"
            value="83.3"
            subtitle="Transactions per Second"
            color="text-buy"
          />
          <MetricCard
            icon={<Zap className="w-6 h-6" />}
            title="Parallel Execution"
            value="85%"
            subtitle="Orders processed in parallel"
            color="text-blue-400"
          />
          <MetricCard
            icon={<BarChart3 className="w-6 h-6" />}
            title="Avg Gas"
            value="147k"
            subtitle="Per order placement"
            color="text-primary"
          />
          <MetricCard
            icon={<TrendingUp className="w-6 h-6" />}
            title="Total Orders"
            value="1,247"
            subtitle="All time"
            color="text-purple-400"
          />
        </div>

        {/* Comparison Table */}
        <div className="card p-6">
          <h2 className="text-xl font-bold mb-6">Performance Comparison</h2>
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-gray-700">
                  <th className="text-left py-3 px-4">Metric</th>
                  <th className="text-right py-3 px-4">Traditional CLOB</th>
                  <th className="text-right py-3 px-4">MonadCLOB</th>
                  <th className="text-right py-3 px-4">Improvement</th>
                </tr>
              </thead>
              <tbody>
                <ComparisonRow
                  metric="TPS"
                  traditional="1-2"
                  monad="50-100"
                  improvement="50x"
                />
                <ComparisonRow
                  metric="Gas per Order"
                  traditional="250k+"
                  monad="~150k"
                  improvement="40%"
                />
                <ComparisonRow
                  metric="Latency"
                  traditional="12s+"
                  monad="<1s"
                  improvement="12x"
                />
                <ComparisonRow
                  metric="Parallel Execution"
                  traditional="0%"
                  monad="80%+"
                  improvement="∞"
                />
              </tbody>
            </table>
          </div>
        </div>

        {/* Execution Breakdown */}
        <div className="card p-6">
          <h2 className="text-xl font-bold mb-6">Execution Breakdown</h2>
          <div className="space-y-4">
            <ProgressBar
              label="Parallel Execution"
              value={85}
              color="bg-buy"
            />
            <ProgressBar
              label="Serial Execution"
              value={15}
              color="bg-primary"
            />
            <ProgressBar
              label="Failed Transactions"
              value={2}
              color="bg-sell"
            />
          </div>
        </div>

        {/* Architecture Highlights */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="card p-6">
            <h3 className="text-lg font-bold mb-4">Key Innovation</h3>
            <p className="text-gray-400 leading-relaxed">
              Different price levels = different storage slots. This enables
              Monad to process orders at different prices in parallel without
              conflicts, achieving 50-100 TPS compared to 1-2 TPS on traditional
              EVM chains.
            </p>
          </div>
          <div className="card p-6">
            <h3 className="text-lg font-bold mb-4">Storage Architecture</h3>
            <div className="space-y-2 text-sm">
              <code className="block bg-gray-900 p-2 rounded text-primary">
                Price $1.00 → slot_A
              </code>
              <code className="block bg-gray-900 p-2 rounded text-buy">
                Price $1.01 → slot_B (parallel ✓)
              </code>
              <code className="block bg-gray-900 p-2 rounded text-blue-400">
                Price $1.02 → slot_C (parallel ✓)
              </code>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function MetricCard({
  icon,
  title,
  value,
  subtitle,
  color,
}: {
  icon: React.ReactNode;
  title: string;
  value: string;
  subtitle: string;
  color: string;
}) {
  return (
    <div className="card p-6">
      <div className="flex items-center justify-between mb-4">
        <span className="text-gray-400">{title}</span>
        <span className={color}>{icon}</span>
      </div>
      <div className={`text-3xl font-bold ${color} mb-1`}>{value}</div>
      <div className="text-sm text-gray-400">{subtitle}</div>
    </div>
  );
}

function ComparisonRow({
  metric,
  traditional,
  monad,
  improvement,
}: {
  metric: string;
  traditional: string;
  monad: string;
  improvement: string;
}) {
  return (
    <tr className="border-b border-gray-800">
      <td className="py-3 px-4">{metric}</td>
      <td className="text-right py-3 px-4 text-gray-400">{traditional}</td>
      <td className="text-right py-3 px-4 text-buy font-semibold">{monad}</td>
      <td className="text-right py-3 px-4 text-primary font-semibold">
        {improvement}
      </td>
    </tr>
  );
}

function ProgressBar({
  label,
  value,
  color,
}: {
  label: string;
  value: number;
  color: string;
}) {
  return (
    <div>
      <div className="flex justify-between mb-2">
        <span className="text-sm">{label}</span>
        <span className="text-sm font-semibold">{value}%</span>
      </div>
      <div className="w-full bg-gray-800 rounded-full h-3">
        <div
          className={`${color} h-3 rounded-full transition-all duration-300`}
          style={{ width: `${value}%` }}
        />
      </div>
    </div>
  );
}
