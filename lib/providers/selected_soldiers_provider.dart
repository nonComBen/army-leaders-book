import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/soldier.dart';

final selectedSoldiersProvider =
    StateNotifierProvider<SelectedSoldiers, List<Soldier>>(
        (ref) => SelectedSoldiers());

class SelectedSoldiers extends StateNotifier<List<Soldier>> {
  SelectedSoldiers() : super([]);

  get soldiers {
    return state;
  }

  void addSoldier(Soldier soldier) {
    state.add(soldier);
  }

  void removeSoldier(Soldier soldier) {
    state.remove(soldier);
  }

  void clearSoldiers() {
    state.clear();
  }
}
