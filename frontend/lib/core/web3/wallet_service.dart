import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web3dart/web3dart.dart';

// Wallet connection state
class WalletState {
  final bool isConnected;
  final EthereumAddress? address;
  final String? error;

  WalletState({
    this.isConnected = false,
    this.address,
    this.error,
  });

  WalletState copyWith({
    bool? isConnected,
    EthereumAddress? address,
    String? error,
  }) {
    return WalletState(
      isConnected: isConnected ?? this.isConnected,
      address: address ?? this.address,
      error: error ?? this.error,
    );
  }
}

// Wallet service for managing wallet connections
class WalletService extends StateNotifier<WalletState> {
  WalletService() : super(WalletState());

  // Connect to MetaMask (placeholder - requires js interop for Flutter web)
  Future<void> connectMetaMask() async {
    try {
      // NOTE: For Flutter web, you'll need to use dart:js to interact with MetaMask
      // This is a placeholder implementation

      // For local development, you can use a test private key
      // NEVER use this in production!
      state = WalletState(
        isConnected: false,
        error: 'MetaMask integration requires additional setup. '
               'For local testing, use the test accounts from Hardhat node.',
      );
    } catch (e) {
      state = WalletState(
        isConnected: false,
        error: e.toString(),
      );
    }
  }

  // Connect with private key (for testing only!)
  Future<void> connectWithPrivateKey(String privateKey) async {
    try {
      final credentials = EthPrivateKey.fromHex(privateKey);
      final address = await credentials.address;

      state = WalletState(
        isConnected: true,
        address: address,
      );
    } catch (e) {
      state = WalletState(
        isConnected: false,
        error: 'Invalid private key: ${e.toString()}',
      );
    }
  }

  // Disconnect wallet
  void disconnect() {
    state = WalletState();
  }

  // Get credentials (for signing transactions)
  Credentials? getCredentials(String privateKey) {
    if (!state.isConnected) return null;
    try {
      return EthPrivateKey.fromHex(privateKey);
    } catch (e) {
      return null;
    }
  }
}

// Provider for wallet service
final walletServiceProvider =
    StateNotifierProvider<WalletService, WalletState>((ref) {
  return WalletService();
});
