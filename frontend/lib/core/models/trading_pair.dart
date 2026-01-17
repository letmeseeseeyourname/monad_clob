import 'package:web3dart/web3dart.dart';

class TradingPair {
  final String pairId;
  final EthereumAddress token0;
  final EthereumAddress token1;
  final BigInt tickSize;
  final BigInt minOrderSize;
  final BigInt bestBid;
  final BigInt bestAsk;
  final bool exists;
  final String symbol;

  TradingPair({
    required this.pairId,
    required this.token0,
    required this.token1,
    required this.tickSize,
    required this.minOrderSize,
    required this.bestBid,
    required this.bestAsk,
    required this.exists,
    required this.symbol,
  });

  factory TradingPair.fromContract(String pairId, List<dynamic> data,
      {String symbol = 'MONAD/USDC'}) {
    return TradingPair(
      pairId: pairId,
      token0: data[0] as EthereumAddress,
      token1: data[1] as EthereumAddress,
      tickSize: data[2] as BigInt,
      minOrderSize: data[3] as BigInt,
      bestBid: data[4] as BigInt,
      bestAsk: data[5] as BigInt,
      exists: data[6] as bool,
      symbol: symbol,
    );
  }

  double get bestBidPrice => bestBid.toDouble() / 1e18;
  double get bestAskPrice => bestAsk.toDouble() / 1e18;
  double get tickSizeDouble => tickSize.toDouble() / 1e18;
  double get minOrderSizeDouble => minOrderSize.toDouble() / 1e18;

  double get spread => bestAskPrice - bestBidPrice;
  double get spreadPercent =>
      bestBidPrice > 0 ? (spread / bestBidPrice) * 100 : 0.0;
}
