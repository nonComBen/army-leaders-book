import 'package:flutter_riverpod/flutter_riverpod.dart';

final subscriptionStateProvider =
    StateNotifierProvider<SubscriptionState, bool>((ref) {
  return SubscriptionState();
});

class SubscriptionState extends StateNotifier<bool> {
  SubscriptionState() : super(true);

  void subscribe() {
    state = true;
  }

  void unSubscribe() {
    state = false;
  }
}
