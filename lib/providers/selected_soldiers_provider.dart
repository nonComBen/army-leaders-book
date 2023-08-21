import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/soldier.dart';

final selectedSoldiersProvider =
    StateNotifierProvider<SelectedSoldiers, List<Soldier>>(
        (ref) => SelectedSoldiers());

class SelectedSoldiers extends StateNotifier<List<Soldier>> {
  SelectedSoldiers() : super([]);

  void addSoldier(Soldier soldier) {
    debugPrint('Soldier added to selected soldiers');
    state.add(soldier);
  }

  void removeSoldier(Soldier soldier) {
    debugPrint('Soldier removed to selected soldiers');
    state.remove(state.firstWhere((element) => element.id == soldier.id));
  }

  void clearSoldiers() {
    state.clear();
  }
}
