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

  final premiumIds = [
    "N5EIa03V7rSma0LDlko6YzGXuXF3", //bhultquist84
    'WtI8grypTbTd0657WmEjgtGophO2', //armynoncomtools
    'i0dn21YEgsfaoQyegu4Aa4AnQn82', //CW2 Lents
    'nqjvb229UIe8JobyXd8Cmddq93t1', //SPC Browne
    'N4qAFiFApucAkM9ouvXjGmgjJoG3', //Andrew Beals
    '8p1IsNvzBfd8SaEnoDSMV6IzRKj2', //1SG Hardel
    '0v4SkNMrtpPrs25hEtMU6uwwYUK2', //Vic Harper
    'ozdVTlpNrraI16I76XjIWePZnX32', //Lascelles May
    'dZnvpPh22EYNgIgCkhzZiVV2VPc2', //Tyler Siegfried
  ];

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
    bool isSubscribed = userSnapshot.docs.first['adFree'] ??
        false || premiumIds.contains(_user.uid);

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
