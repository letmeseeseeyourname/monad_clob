import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Performance Analytics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Key Metrics Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildMetricCard(
                  title: 'TPS',
                  value: '83.3',
                  subtitle: 'Transactions per Second',
                  icon: Icons.speed,
                  color: Colors.green,
                ),
                _buildMetricCard(
                  title: 'Parallel Execution',
                  value: '85%',
                  subtitle: 'Orders processed in parallel',
                  icon: Icons.multiple_stop,
                  color: Colors.blue,
                ),
                _buildMetricCard(
                  title: 'Avg Gas',
                  value: '147k',
                  subtitle: 'Per order placement',
                  icon: Icons.local_gas_station,
                  color: Colors.orange,
                ),
                _buildMetricCard(
                  title: 'Total Orders',
                  value: '1,247',
                  subtitle: 'All time',
                  icon: Icons.receipt_long,
                  color: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Performance Chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TPS Over Time',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.show_chart,
                            size: 48,
                            color: Colors.white24,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Chart Integration Coming Soon',
                            style: TextStyle(
                              color: Colors.white38,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Use fl_chart for visualization',
                            style: TextStyle(
                              color: Colors.white24,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Order Distribution
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Distribution by Price',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.bar_chart,
                            size: 48,
                            color: Colors.white24,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Bar Chart Coming Soon',
                            style: TextStyle(
                              color: Colors.white38,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Execution Breakdown
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Execution Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildProgressIndicator(
                      label: 'Parallel Execution',
                      value: 0.85,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildProgressIndicator(
                      label: 'Serial Execution',
                      value: 0.15,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    _buildProgressIndicator(
                      label: 'Failed Transactions',
                      value: 0.02,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Comparison Table
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Performance Comparison',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Table(
                      border: TableBorder.all(color: Colors.white12),
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            color: Colors.white10,
                          ),
                          children: [
                            _buildTableCell('Metric', isHeader: true),
                            _buildTableCell('Traditional', isHeader: true),
                            _buildTableCell('MonadCLOB', isHeader: true),
                          ],
                        ),
                        TableRow(
                          children: [
                            _buildTableCell('TPS'),
                            _buildTableCell('1-2'),
                            _buildTableCell('50-100',
                                highlight: Colors.green),
                          ],
                        ),
                        TableRow(
                          children: [
                            _buildTableCell('Gas/Order'),
                            _buildTableCell('250k+'),
                            _buildTableCell('~150k', highlight: Colors.green),
                          ],
                        ),
                        TableRow(
                          children: [
                            _buildTableCell('Latency'),
                            _buildTableCell('12s+'),
                            _buildTableCell('<1s', highlight: Colors.green),
                          ],
                        ),
                        TableRow(
                          children: [
                            _buildTableCell('Parallel'),
                            _buildTableCell('0%'),
                            _buildTableCell('80%+', highlight: Colors.green),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                Icon(icon, color: color, size: 24),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator({
    required String label,
    required double value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              '${(value * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildTableCell(String text,
      {bool isHeader = false, Color? highlight}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: highlight ?? Colors.white,
        ),
      ),
    );
  }
}
