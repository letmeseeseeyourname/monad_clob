import 'package:flutter/material.dart';

class TradingScreen extends StatefulWidget {
  const TradingScreen({super.key});

  @override
  State<TradingScreen> createState() => _TradingScreenState();
}

class _TradingScreenState extends State<TradingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'MonadCLOB',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'MONAD/USDC',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement wallet connection
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Wallet connection coming soon...'),
                ),
              );
            },
            icon: const Icon(Icons.account_balance_wallet),
            label: const Text('Connect Wallet'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 1200) {
            // Desktop layout
            return Row(
              children: [
                // Order Book (left)
                Expanded(
                  flex: 3,
                  child: _buildOrderBookSection(),
                ),
                // Chart (center)
                Expanded(
                  flex: 5,
                  child: _buildChartSection(),
                ),
                // Trade Form (right)
                Expanded(
                  flex: 3,
                  child: _buildTradeFormSection(),
                ),
              ],
            );
          } else {
            // Mobile layout
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildChartSection(),
                  Row(
                    children: [
                      Expanded(child: _buildOrderBookSection()),
                      Expanded(child: _buildTradeFormSection()),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Theme.of(context).cardColor,
        child: _buildOrderHistorySection(),
      ),
    );
  }

  Widget _buildOrderBookSection() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          _buildSectionHeader('Order Book'),
          Expanded(
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) {
                final isBid = index < 10;
                final price = isBid ? 1.00 - (index * 0.01) : 1.01 + ((index - 10) * 0.01);
                final amount = 100.0 + (index * 10);

                return _buildOrderBookLevel(
                  price: price,
                  amount: amount,
                  total: price * amount,
                  isBid: isBid,
                  depth: (10 - (index % 10)) / 10,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderBookLevel({
    required double price,
    required double amount,
    required double total,
    required bool isBid,
    required double depth,
  }) {
    final color = isBid ? Colors.green : Colors.red;

    return InkWell(
      onTap: () {
        // TODO: Auto-fill trade form with this price
      },
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Stack(
          children: [
            // Depth bar
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: MediaQuery.of(context).size.width * 0.2 * depth,
              child: Container(
                color: color.withOpacity(0.2),
              ),
            ),
            // Text
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  price.toStringAsFixed(2),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  amount.toStringAsFixed(2),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  total.toStringAsFixed(2),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          _buildSectionHeader('Price Chart'),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.show_chart,
                    size: 64,
                    color: Colors.white24,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Price Chart Coming Soon',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Integrate fl_chart for real-time price visualization',
                    style: TextStyle(
                      color: Colors.white24,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeFormSection() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          _buildSectionHeader('Place Order'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Buy/Sell Toggle
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('BUY'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text('SELL'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Price Input
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Price (USDC)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),

                  // Amount Input
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Amount (MONAD)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.account_balance),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),

                  // Total Display
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Total:'),
                        Text(
                          '0.00 USDC',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Balance Display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Available:',
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        '0.00 USDC',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Submit Button
                  ElevatedButton(
                    onPressed: null, // Disabled until wallet connected
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Connect Wallet to Trade',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Your Orders',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: Center(
            child: Text(
              'Connect wallet to view your orders',
              style: TextStyle(
                color: Colors.white38,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white12,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
