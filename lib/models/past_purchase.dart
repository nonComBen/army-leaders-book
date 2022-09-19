import 'package:flutter/widgets.dart';
import 'package:leaders_book/constants.dart';

enum PurchaseType {
  subscriptionPurchase,
  nonSubscriptionPurchase,
}

enum Store {
  googlePlay,
  appStore,
}

enum Status {
  pending,
  completed,
  active,
  expired,
}

@immutable
class PastPurchase {
  final PurchaseType type;
  final Store store;
  final String orderId;
  final String productId;
  final DateTime purchaseDate;
  final DateTime expiryDate;
  final Status status;

  String get title {
    switch (productId) {
      case storeKeyAndroidTwo:
        return 'androidTwo';
      case storeKeyIOS:
        return 'iOSPremium';
      case storeKeyAndroidOne:
        return 'androidOne';
      default:
        return productId;
    }
  }

  PastPurchase.fromJson(Map<String, dynamic> json)
      : type = _typeFromString(json['type'] as String),
        store = _storeFromString(json['iapSource'] as String),
        orderId = json['orderId'] as String,
        productId = json['productId'] as String,
        purchaseDate = DateTime.now(),
        expiryDate = null,
        status = _statusFromString(json['status'] as String);
}

PurchaseType _typeFromString(String type) {
  switch (type) {
    case 'NON_SUBSCRIPTION':
      return PurchaseType.nonSubscriptionPurchase;
    case 'SUBSCRIPTION':
      return PurchaseType.subscriptionPurchase;
    default:
      throw ArgumentError.value(type, '$type is not a supported type');
  }
}

Store _storeFromString(String store) {
  switch (store) {
    case 'google_play':
      return Store.googlePlay;
    case 'app_store':
      return Store.appStore;
    default:
      throw ArgumentError.value(store, '$store is not a supported store');
  }
}

Status _statusFromString(String status) {
  switch (status) {
    case 'PENDING':
      return Status.pending;
    case 'COMPLETED':
      return Status.completed;
    case 'ACTIVE':
      return Status.active;
    case 'EXPIRED':
      return Status.expired;
    default:
      throw ArgumentError.value(status, '$status is not a supported status');
  }
}
