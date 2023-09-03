// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter_test/flutter_test.dart';
import 'package:leaders_book/models/soldier.dart';
import 'package:leaders_book/providers/selected_soldiers_provider.dart';

import 'filtered_soldiers_provider_test.dart';

void main() {
  late SelectedSoldiers sut;

  setUp(() {
    sut = SelectedSoldiers();
  });

  test(
    "initial values are correct",
    () async {
      expect(sut.state, []);
    },
  );

  group('adding, removing, and clearing selected soldiers works', () {
    test(
      "adding soldiers works",
      () async {
        sut.addSoldier(allSoldiers[0]);
        expect(sut.state, [allSoldiers[0]]);
      },
    );
    test(
      "removing soldiers works",
      () async {
        sut.addSoldier(allSoldiers[0]);
        expect(sut.state.length, 1);
        sut.removeSoldier(allSoldiers[0]);
        expect(sut.state, []);
      },
    );
    test(
      "clearing soldiers works",
      () async {
        for (Soldier soldier in allSoldiers) {
          sut.addSoldier(soldier);
        }
        expect(sut.state.length, 5);
        sut.clearSoldiers();
        expect(sut.state, []);
      },
    );
  });
}
