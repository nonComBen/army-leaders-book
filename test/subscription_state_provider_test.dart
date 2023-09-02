// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter_test/flutter_test.dart';
import 'package:leaders_book/providers/subscription_state.dart';

void main() {
  late SubscriptionState sut;

  setUp(() {
    sut = SubscriptionState();
  });

  test('initial values are correct', () {
    expect(sut.state, false);
  });

  group('change subscription state', () {
    test(
      "state changes after subscribing and unsubscribing",
      () async {
        expect(sut.state, false);
        sut.subscribe();
        expect(sut.state, true);
        sut.unSubscribe();
        expect(sut.state, false);
      },
    );
  });
}
