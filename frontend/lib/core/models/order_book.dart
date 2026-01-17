class OrderBookLevel {
  final double price;
  final double amount;
  final int orderCount;

  OrderBookLevel({
    required this.price,
    required this.amount,
    required this.orderCount,
  });

  factory OrderBookLevel.fromContract(List<dynamic> data) {
    return OrderBookLevel(
      price: (data[0] as BigInt).toDouble() / 1e18,
      amount: (data[1] as BigInt).toDouble() / 1e18,
      orderCount: (data[2] as BigInt).toInt(),
    );
  }

  double get total => price * amount;
}

class OrderBookData {
  final List<OrderBookLevel> bids;
  final List<OrderBookLevel> asks;
  final DateTime lastUpdate;

  OrderBookData({
    required this.bids,
    required this.asks,
    required this.lastUpdate,
  });

  double get spread {
    if (bids.isEmpty || asks.isEmpty) return 0.0;
    return asks.first.price - bids.first.price;
  }

  double get spreadPercent {
    if (bids.isEmpty || spread == 0.0) return 0.0;
    return (spread / bids.first.price) * 100;
  }

  double? get midPrice {
    if (bids.isEmpty || asks.isEmpty) return null;
    return (bids.first.price + asks.first.price) / 2;
  }

  OrderBookLevel? get bestBid => bids.isNotEmpty ? bids.first : null;
  OrderBookLevel? get bestAsk => asks.isNotEmpty ? asks.first : null;
}
