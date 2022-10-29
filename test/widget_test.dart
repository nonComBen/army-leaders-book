// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_platform_interface/src/in_app_purchase_platform_addition.dart';
import 'package:leaders_book/classes/iap_connection.dart';

import 'package:leaders_book/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    IAPConnection.instance = TestIAPConnection();
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
      prefs: null,
    ));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}

class TestIAPConnection implements InAppPurchase {
  @override
  Future<bool> buyConsumable(
      {PurchaseParam purchaseParam, bool autoConsume = true}) {
    return Future.value(false);
  }

  @override
  Future<bool> buyNonConsumable({PurchaseParam purchaseParam}) {
    return Future.value(false);
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) {
    return Future.value();
  }

  @override
  Future<bool> isAvailable() {
    return Future.value(false);
  }

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers) {
    return Future.value(ProductDetailsResponse(
      productDetails: [],
      notFoundIDs: [],
    ));
  }

  @override
  Stream<List<PurchaseDetails>> get purchaseStream =>
      Stream.value(<PurchaseDetails>[]);

  @override
  Future<void> restorePurchases({String applicationUserName}) {
    // TODO: implement restorePurchases
    throw UnimplementedError();
  }

  @override
  T getPlatformAddition<T extends InAppPurchasePlatformAddition>() {
    // TODO: implement getPlatformAddition
    throw UnimplementedError();
  }
}
