import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../classes/iap_connection.dart';
import '../classes/iap_repo.dart';
import '../constants.dart';
import './subscription_state.dart';
import '../models/purchasable_product.dart';
import '../models/store_state.dart';

class SubscriptionPurchases extends ChangeNotifier {
  final SubscriptionState subscriptionState;
  final IAPRepo iapRepo;
  StreamSubscription<List<PurchaseDetails>> _subscription;
  final iapConnection = IAPConnection.instance;
  StoreState storeState = StoreState.loading;
  List<PurchasableProduct> products = [];

  SubscriptionPurchases(this.subscriptionState, this.iapRepo) {
    if (!kIsWeb) {
      final purchaseUpdated = iapConnection.purchaseStream;
      _subscription = purchaseUpdated.listen(
        _onPurchaseUpdate,
        onDone: _updateStreamOnDone,
        onError: _updateStreamOnError,
      );
      iapConnection.restorePurchases();
      iapRepo.addListener(purchasesUpdate);
      loadPurchases();
    }
  }

  Future<void> loadPurchases() async {
    final available = await iapConnection.isAvailable();
    if (!available) {
      storeState = StoreState.notAvailable;
      notifyListeners();
      return;
    }
    const ids = <String>{
      storeKeyAndroidOne,
      storeKeyAndroidTwo,
      storeKeyIOS,
    };
    final response = await iapConnection.queryProductDetails(ids);
    for (var element in response.notFoundIDs) {
      // ignore: avoid_print
      print('Purchase $element not found');
    }
    products =
        response.productDetails.map((e) => PurchasableProduct(e)).toList();
    storeState = StoreState.available;
    notifyListeners();
  }

  Future<void> buy(PurchasableProduct product) async {
    final purchaseParam = PurchaseParam(productDetails: product.productDetails);
    await iapConnection.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach(_handlePurchase);
    notifyListeners();
  }

  void _handlePurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.status == PurchaseStatus.purchased ||
        purchaseDetails.status == PurchaseStatus.restored) {
      var validPurchase = false;
      try {
        validPurchase = await _verifyPurchase(purchaseDetails);
      } on Exception catch (e) {
        // ignore: avoid_print
        print('Error: $e');
      }
      if (validPurchase) {
        subscriptionState.subscribe();
      }
    }

    if (purchaseDetails.pendingCompletePurchase) {
      iapConnection.completePurchase(purchaseDetails);
    }
  }

  void _updateStreamOnDone() {
    _subscription.cancel();
  }

  void _updateStreamOnError(dynamic error) {
    //Handle error here
  }

  void purchasesUpdate() {
    var subscriptions = <PurchasableProduct>[];
    // Get a list of purchasable products for the subscription and upgrade.
    // This should be 1 per type.
    if (products.isNotEmpty) {
      subscriptions = products.toList();
    }

    // Set the subscription in the counter logic and show/hide purchased on the
    // purchases page.
    if (iapRepo.hasActiveSubscription) {
      subscriptionState.subscribe();
      for (final element in subscriptions) {
        _updateStatus(element, ProductStatus.purchased);
      }
    } else {
      // subscriptionState.unSubscribe();
      for (final element in subscriptions) {
        _updateStatus(element, ProductStatus.purchasable);
      }
    }
  }

  void _updateStatus(PurchasableProduct product, ProductStatus status) {
    if (product.status != ProductStatus.purchased) {
      product.status = ProductStatus.purchased;
      notifyListeners();
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    var functions = FirebaseFunctions.instance;
    final callable = functions.httpsCallable('verifyPurchase');
    final results = await callable({
      'source': purchaseDetails.verificationData.source,
      'verificationData':
          purchaseDetails.verificationData.serverVerificationData,
      'productId': purchaseDetails.productID,
    });
    return results.data as bool;
  }
}
