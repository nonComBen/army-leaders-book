import 'package:flutter_riverpod/legacy.dart';

final subscriptionStateProvider =
    StateNotifierProvider<SubscriptionState, bool>((ref) {
  return SubscriptionState();
});

class SubscriptionState extends StateNotifier<bool> {
  SubscriptionState() : super(false);

  void subscribe() {
    state = true;
  }

  void unSubscribe() {
    state = false;
  }
}
