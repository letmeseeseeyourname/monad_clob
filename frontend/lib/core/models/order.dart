import 'package:web3dart/web3dart.dart';

enum OrderStatus {
  active,
  filled,
  cancelled,
}

class Order {
  final BigInt orderId;
  final EthereumAddress trader;
  final BigInt amount;
  final BigInt price;
  final DateTime timestamp;
  final DateTime? expiry;
  final bool isBuy;
  final OrderStatus status;

  Order({
    required this.orderId,
    required this.trader,
    required this.amount,
    required this.price,
    required this.timestamp,
    this.expiry,
    required this.isBuy,
    required this.status,
  });

  factory Order.fromContract(BigInt orderId, List<dynamic> data) {
    return Order(
      orderId: orderId,
      trader: data[0] as EthereumAddress,
      amount: data[1] as BigInt,
      price: data[2] as BigInt,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (data[3] as BigInt).toInt() * 1000,
      ),
      expiry: (data[4] as BigInt) == BigInt.zero
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              (data[4] as BigInt).toInt() * 1000,
            ),
      isBuy: data[5] as bool,
      status: OrderStatus.values[(data[6] as BigInt).toInt()],
    );
  }

  double get priceAsDouble => price.toDouble() / 1e18;
  double get amountAsDouble => amount.toDouble() / 1e18;

  String get statusString {
    switch (status) {
      case OrderStatus.active:
        return 'Active';
      case OrderStatus.filled:
        return 'Filled';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get sideString => isBuy ? 'BUY' : 'SELL';
}
