import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import '../constants/contract_constants.dart';

// Web3 Client Provider
final web3ClientProvider = Provider<Web3Client>((ref) {
  return Web3Client(RPC_URL, http.Client());
});

// Contract ABI Provider
final contractABIProvider = Provider<ContractAbi>((ref) {
  return ContractAbi.fromJson(
    CLOB_CONTRACT_ABI.toString(),
    'MonadCLOB',
  );
});

// Deployed Contract Provider
final deployedContractProvider = Provider<DeployedContract>((ref) {
  final abi = ref.watch(contractABIProvider);
  return DeployedContract(
    abi,
    EthereumAddress.fromHex(CLOB_CONTRACT_ADDRESS),
  );
});

// Chain ID Provider
final chainIdProvider = Provider<int>((ref) => CHAIN_ID);
