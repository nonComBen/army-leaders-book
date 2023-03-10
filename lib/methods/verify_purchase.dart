import 'package:cloud_functions/cloud_functions.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

Future<bool> listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList) async {
  bool isSubscribed = false;
  for (var purchaseDetails in purchaseDetailsList) {
    if (purchaseDetails.status == PurchaseStatus.pending) {
      //_showPendingUI();
    } else {
      if (purchaseDetails.status == PurchaseStatus.error) {
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        bool valid = await verifyPurchase(purchaseDetails);
        if (valid) {
          isSubscribed = true;
        } else {
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
  FirebaseFunctions functions = FirebaseFunctions.instance;
  final callable = functions.httpsCallable('verifyPurchase');
  final results = await callable({
    'source': purchaseDetails.verificationData.source,
    'verificationData': purchaseDetails.verificationData.serverVerificationData,
    'productId': purchaseDetails.productID,
  });
  return results.data as bool;
}
