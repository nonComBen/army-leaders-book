import 'package:flutter/material.dart';

class SubscriptionState extends ChangeNotifier {
  SubscriptionState();
  bool _isSubscribed = true;

  void subscribe() {
    _isSubscribed = true;
    notifyListeners();
  }

  void unSubscribe() {
    _isSubscribed = false;
    notifyListeners();
  }

  bool get isSubscribed => _isSubscribed;
}
