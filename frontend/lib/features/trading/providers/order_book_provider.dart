import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/order_book.dart';
import '../../../core/web3/contract_service.dart';
import '../../../core/constants/contract_constants.dart';

// Order book state
class OrderBookState {
  final OrderBookData? data;
  final bool isLoading;
  final String? error;

  OrderBookState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  OrderBookState copyWith({
    OrderBookData? data,
    bool? isLoading,
    String? error,
  }) {
    return OrderBookState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Order book provider
class OrderBookNotifier extends StateNotifier<OrderBookState> {
  final ContractService contractService;
  Timer? _pollTimer;

  OrderBookNotifier(this.contractService) : super(OrderBookState()) {
    // Start polling order book
    _startPolling();
  }

  // Fetch order book from blockchain
  Future<void> fetchOrderBook() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final orderBook = await contractService.getOrderBookDepth(
        MONAD_USDC_PAIR_ID,
        10, // Get top 10 levels
      );

      state = OrderBookState(
        data: orderBook,
        isLoading: false,
      );
    } catch (e) {
      state = OrderBookState(
        isLoading: false,
        error: 'Failed to fetch order book: ${e.toString()}',
      );
    }
  }

  // Start polling every 2 seconds
  void _startPolling() {
    fetchOrderBook(); // Initial fetch
    _pollTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => fetchOrderBook(),
    );
  }

  // Stop polling
  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}

// Provider
final orderBookProvider =
    StateNotifierProvider<OrderBookNotifier, OrderBookState>((ref) {
  final contractService = ref.watch(contractServiceProvider);
  return OrderBookNotifier(contractService);
});
