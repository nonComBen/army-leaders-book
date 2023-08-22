import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaders_book/providers/auth_provider.dart';
import 'package:leaders_book/models/past_purchase.dart';
import 'package:leaders_book/models/leader.dart';
import 'package:leaders_book/providers/subscription_state.dart';

final iapRepoProvider = Provider<IAPRepo>((ref) {
  return IAPRepo(
    ref.read(subscriptionStateProvider.notifier),
    ref.read(authProvider).currentUser(),
  );
});

class IAPRepo {
  User? _user;
  final SubscriptionState subState;

  IAPRepo(this.subState, this._user) {
    updatePurchases();
    listenToLogin();
  }

  Leader? _leader;
  bool hasActiveSubscription = false;
  List<PastPurchase> purchases = [];

  bool get isLoggedIn => _user != null;
  Leader? get user => _leader;

  final premiumIds = [
    'N5EIa03V7rSma0LDlko6YzGXuXF3', //bhultquist84
    'WtI8grypTbTd0657WmEjgtGophO2', //armynoncomtools
    'i0dn21YEgsfaoQyegu4Aa4AnQn82', //CW2 Lents
    'nqjvb229UIe8JobyXd8Cmddq93t1', //SPC Browne
    'N4qAFiFApucAkM9ouvXjGmgjJoG3', //Andrew Beals
    '8p1IsNvzBfd8SaEnoDSMV6IzRKj2', //1SG Hardel
    '0v4SkNMrtpPrs25hEtMU6uwwYUK2', //Vic Harper
    'ozdVTlpNrraI16I76XjIWePZnX32', //Lascelles May
    'dZnvpPh22EYNgIgCkhzZiVV2VPc2', //Tyler Siegfried
    '9GtKo4IEbMRSEUnntMpRZYwg1MF3', //Jason Infante
    // '8o9XIyQykXdBe2dZKgTPDfSdD7Y2',
  ];

  void listenToLogin() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
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
    final purchaseSnapshot = await FirebaseFirestore.instance
        .collection('purchases')
        .where('userId', isEqualTo: _user!.uid)
        .where('status', isEqualTo: 'ACTIVE')
        .get();

    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userId', isEqualTo: _user!.uid)
        .get();

    _leader = Leader.fromSnapshot(userSnapshot.docs.first);
    bool isSubscribed =
        userSnapshot.docs.first['adFree'] || premiumIds.contains(_user!.uid);

    purchases = purchaseSnapshot.docs.map((document) {
      return PastPurchase.fromJson(document.data());
    }).toList();

    hasActiveSubscription = purchases.isNotEmpty || isSubscribed;

    if (hasActiveSubscription) {
      subState.subscribe();
    }
  }
}
