// ignore_for_file: avoid_print

import 'package:cloud_functions/cloud_functions.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

Future<bool> listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList) async {
  bool isSubscribed = false;
  print('Listen to Purchase got called.');
  for (var purchaseDetails in purchaseDetailsList) {
    print(purchaseDetails.status);
    if (purchaseDetails.status == PurchaseStatus.pending) {
      //_showPendingUI();
    } else {
      if (purchaseDetails.status == PurchaseStatus.error) {
        print(purchaseDetails.error);
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        bool valid = await verifyPurchase(purchaseDetails);
        if (valid) {
          print('purchase is valid');
          isSubscribed = true;
        } else {
          print('Purchase is not valid');
          isSubscribed = false;
        }
      }
      if (purchaseDetails.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchaseDetails);
      }
      if (isSubscribed) {
        break;
      }
    }
  }
  return isSubscribed;
}

Future<bool> verifyPurchase(PurchaseDetails purchaseDetails) async {
  print('Verifying purchase');
  FirebaseFunctions functions = FirebaseFunctions.instance;
  final callable = functions.httpsCallable('verifyPurchase');
  final results = await callable({
    'source': purchaseDetails.verificationData.source,
    'verificationData': purchaseDetails.verificationData.serverVerificationData,
    'productId': purchaseDetails.productID,
  });
  print('Result: ${results.data}');
  return results.data as bool;
}
