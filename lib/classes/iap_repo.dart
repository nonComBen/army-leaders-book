import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:leaders_book/constants.dart';
import 'package:leaders_book/models/past_purchase.dart';
import 'package:leaders_book/models/user.dart';

class IAPRepo extends ChangeNotifier {
  User _user;
  UserObj _userObj;
  bool hasActiveSubscription = false;
  List<PastPurchase> purchases = [];

  StreamSubscription<User> _userSubscription;
  StreamSubscription<QuerySnapshot> _purchaseSubscription;

  IAPRepo(this._user) {
    updatePurchases();
    listenToLogin();
  }

  bool get isLoggedIn => _user != null;
  UserObj get user => _userObj;

  void listenToLogin() {
    _userSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      _user = user;
      updatePurchases();
    });
  }

  void updatePurchases() async {
    if (_user == null) {
      purchases = [];
      hasActiveSubscription = false;
      return;
    }
    _purchaseSubscription?.cancel();

    final snapshot = await FirebaseFirestore.instance
        .collection('purchases')
        .where('userId', isEqualTo: _user.uid)
        .get();

    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userId', isEqualTo: _user.uid)
        .get();

    _userObj = UserObj.fromSnapshot(userSnapshot.docs.first);
    bool isSubscribed = userSnapshot.docs.first['adFree'] ?? false;

    for (DocumentSnapshot doc in snapshot.docs) {
      Timestamp expiry = doc['expiryDate'];
      if (expiry.toDate().isBefore(DateTime.now())) {
        doc.reference.update({'status': 'EXPIRED', 'userId': _user.uid});
      } else if (doc['userId'] == null) {
        doc.reference.update({'userId': _user.uid});
      }
    }

    purchases = snapshot.docs.map((document) {
      var data = document.data();
      return PastPurchase.fromJson(data);
    }).toList();

    hasActiveSubscription = purchases.any((element) =>
            (element.productId == storeKeyAndroidOne ||
                element.productId == storeKeyAndroidTwo ||
                element.productId == storeKeyIOS) &&
            element.status != Status.expired) ||
        isSubscribed;

    notifyListeners();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}
