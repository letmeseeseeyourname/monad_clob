import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web3dart/web3dart.dart';
import '../constants/contract_constants.dart';
import '../models/order_book.dart';
import '../models/trading_pair.dart';
import 'web3_provider.dart';

class ContractService {
  final Web3Client client;
  final DeployedContract contract;

  ContractService({
    required this.client,
    required this.contract,
  });

  // Get trading pair information
  Future<TradingPair> getPair(String pairId) async {
    final function = contract.function('getPair');
    final result = await client.call(
      contract: contract,
      function: function,
      params: [hexToBytes(pairId)],
    );

    return TradingPair.fromContract(pairId, result);
  }

  // Get best bid price
  Future<BigInt> getBestBid(String pairId) async {
    final function = contract.function('getBestBid');
    final result = await client.call(
      contract: contract,
      function: function,
      params: [hexToBytes(pairId)],
    );

    return result.first as BigInt;
  }

  // Get best ask price
  Future<BigInt> getBestAsk(String pairId) async {
    final function = contract.function('getBestAsk');
    final result = await client.call(
      contract: contract,
      function: function,
      params: [hexToBytes(pairId)],
    );

    return result.first as BigInt;
  }

  // Get order book depth
  Future<OrderBookData> getOrderBookDepth(String pairId, int levels) async {
    final function = contract.function('getOrderBookDepth');
    final result = await client.call(
      contract: contract,
      function: function,
      params: [hexToBytes(pairId), BigInt.from(levels)],
    );

    final bidsData = result[0] as List<dynamic>;
    final asksData = result[1] as List<dynamic>;

    final bids = bidsData
        .map((bid) => OrderBookLevel.fromContract(bid))
        .where((level) => level.price > 0)
        .toList();

    final asks = asksData
        .map((ask) => OrderBookLevel.fromContract(ask))
        .where((level) => level.price > 0)
        .toList();

    return OrderBookData(
      bids: bids,
      asks: asks,
      lastUpdate: DateTime.now(),
    );
  }

  // Get user balance
  Future<BigInt> getUserBalance(
    EthereumAddress user,
    EthereumAddress token,
  ) async {
    final function = contract.function('getUserBalance');
    final result = await client.call(
      contract: contract,
      function: function,
      params: [user, token],
    );

    return result.first as BigInt;
  }

  // Place limit order (requires signed transaction)
  Future<String> placeLimitOrder({
    required Credentials credentials,
    required String pairId,
    required bool isBuy,
    required BigInt price,
    required BigInt amount,
    required int expiry,
  }) async {
    final function = contract.function('placeLimitOrder');

    final transaction = Transaction.callContract(
      contract: contract,
      function: function,
      parameters: [
        hexToBytes(pairId),
        isBuy,
        price,
        amount,
        BigInt.from(expiry),
      ],
    );

    final txHash = await client.sendTransaction(
      credentials,
      transaction,
      chainId: CHAIN_ID,
    );

    return txHash;
  }

  // Cancel order
  Future<String> cancelOrder({
    required Credentials credentials,
    required BigInt orderId,
  }) async {
    final function = contract.function('cancelOrder');

    final transaction = Transaction.callContract(
      contract: contract,
      function: function,
      parameters: [orderId],
    );

    final txHash = await client.sendTransaction(
      credentials,
      transaction,
      chainId: CHAIN_ID,
    );

    return txHash;
  }

  // Deposit tokens
  Future<String> deposit({
    required Credentials credentials,
    required EthereumAddress token,
    required BigInt amount,
  }) async {
    final function = contract.function('deposit');

    final transaction = Transaction.callContract(
      contract: contract,
      function: function,
      parameters: [token, amount],
    );

    final txHash = await client.sendTransaction(
      credentials,
      transaction,
      chainId: CHAIN_ID,
    );

    return txHash;
  }

  // Helper to convert hex string to bytes
  List<int> hexToBytes(String hex) {
    if (hex.startsWith('0x')) {
      hex = hex.substring(2);
    }
    final bytes = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return bytes;
  }
}

// Provider for ContractService
final contractServiceProvider = Provider<ContractService>((ref) {
  final client = ref.watch(web3ClientProvider);
  final contract = ref.watch(deployedContractProvider);

  return ContractService(
    client: client,
    contract: contract,
  );
});
