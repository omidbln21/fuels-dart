import 'package:flutter_fuels/model/call_result.dart';
import 'package:flutter_fuels/model/transaction_cost.dart';
import 'package:flutter_fuels/utils/address_utils.dart';
import 'package:flutter_fuels/utils/mnemonic_utils.dart';
import 'package:flutter_fuels/wallet/dart_wallet_unlocked.dart';

import 'platform_impl/stub_wallet.dart'
    if (dart.library.io) 'platform_impl/mobile_wallet.dart'
    if (dart.library.html) 'platform_impl/web_wallet.dart';

class FuelWallet {
  final DartWalletUnlocked _walletUnlocked;

  FuelWallet(this._walletUnlocked);

  static final _wallet = FuelWalletImpl();

  /// Generates a mnemonic phrase and a wallet from it
  static Future<FuelWallet> generateNewWallet({
    required String networkUrl,
  }) async {
    final walletUnlocked =
        await _wallet.generateNewWallet(networkUrl: networkUrl);
    return FuelWallet(walletUnlocked);
  }

  /// Imports the wallet from the provided private key. Mnemonic phrase would
  /// be absent, cause it's impossible to infer from private key
  static Future<FuelWallet> newFromPrivateKey({
    required String networkUrl,
    required String privateKey,
  }) async {
    final walletUnlocked = await _wallet.newFromPrivateKey(
      networkUrl: networkUrl,
      privateKey: privateKey,
    );
    return FuelWallet(walletUnlocked);
  }

  /// Imports the wallet from the provided mnemonic phrase
  static Future<FuelWallet> newFromMnemonicPhrase({
    required String networkUrl,
    required String mnemonic,
  }) async {
    validateMnemonicPhrase(mnemonic);
    final walletUnlocked = await _wallet.newFromMnemonic(
      networkUrl: networkUrl,
      mnemonic: mnemonic,
    );
    return FuelWallet(walletUnlocked);
  }

  /// Imports the wallet from the provided mnemonic phrase and derivation path
  static Future<FuelWallet> newFromMnemonicPhraseAndPath({
    required String networkUrl,
    required String mnemonic,
    required String derivationPath,
  }) async {
    validateMnemonicPhrase(mnemonic);
    final walletUnlocked = await _wallet.newFromMnemonicAndPath(
        networkUrl: networkUrl,
        mnemonic: mnemonic,
        derivationPath: derivationPath);
    return FuelWallet(walletUnlocked);
  }

  /// Derives the wallet from the provided mnemonic and index. Constructs the
  /// derivation path from the provided index and the conformed Fuel's template
  /// "m/44'/1179993420'/$index'/0/0" and imports the wallet using this path
  static Future<FuelWallet> newFromMnemonicPhraseAndIndex({
    required String networkUrl,
    required String mnemonic,
    required int index,
  }) async {
    if (index < 0) {
      throw Exception('Index should be positive');
    }
    final derivationPath = "m/44'/1179993420'/$index'/0/0";
    return await FuelWallet.newFromMnemonicPhraseAndPath(
        networkUrl: networkUrl,
        mnemonic: mnemonic,
        derivationPath: derivationPath);
  }

  String? get mnemonicPhrase => _walletUnlocked.mnemonicPhrase;

  String get bech32Address => _walletUnlocked.bech32Address;

  String get b256Address => addHexPrefix(_walletUnlocked.b256Address);

  String get privateKey => _walletUnlocked.privateKey;

  String get networkUrl => _walletUnlocked.networkUrl;

  Future<String> transfer({
    required String destinationB256Address,
    required int fractionalAmount,
    required String assetId,
  }) async {
    final transferRequest = await _walletUnlocked.genTransferTransactionRequest(
        destinationB256Address: destinationB256Address,
        fractionalAmount: fractionalAmount,
        assetId: assetId);
    return _walletUnlocked.sendTransaction(
        transactionRequestHexOrJson: transferRequest);
  }

  Future<String> signMessage({
    required String message,
  }) {
    return _walletUnlocked.signMessage(message: message);
  }

  /// Takes hex string on mobile and json tx request on web
  Future<String> sendTransaction({
    required String transactionRequestHexOrJson,
  }) {
    return _walletUnlocked.sendTransaction(
        transactionRequestHexOrJson: transactionRequestHexOrJson);
  }

  /// Takes hex string on mobile and json tx request on web
  Future<CallResult> simulateTransaction({
    required String transactionRequestHexOrJson,
  }) {
    return _walletUnlocked.simulateTransaction(
        transactionRequestHexOrJson: transactionRequestHexOrJson);
  }

  /// Takes hex string on mobile and json tx request on web
  Future<TransactionCost> getTransactionCost({
    required String transactionRequestHexOrJson,
  }) async {
    return _walletUnlocked.getTransactionCost(
        transactionRequestHexOrJson: transactionRequestHexOrJson);
  }

  /// Returns hex string on mobile and json tx request on web
  Future<String> genTransferTransactionRequest(
      {required String destinationB256Address,
      required int fractionalAmount,
      required String assetId}) {
    return _walletUnlocked.genTransferTransactionRequest(
      destinationB256Address: destinationB256Address,
      fractionalAmount: fractionalAmount,
      assetId: assetId,
    );
  }
}
