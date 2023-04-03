import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaders_book/providers/soldiers_provider.dart';

import '../models/soldier.dart';

final filteredSoldiersProvider =
    StateNotifierProvider<FilteredSoldiers, List<Soldier>>(
        (ref) => FilteredSoldiers(ref.watch(soldiersProvider)));

class FilteredSoldiers extends StateNotifier<List<Soldier>> {
  FilteredSoldiers(this.allSoldiers) : super(allSoldiers);
  final List<Soldier> allSoldiers;

  get soldiers => state;

  void filter(String section) {
    if (section == "All") {
      state = allSoldiers;
    } else {
      state =
          allSoldiers.where((element) => element.section == section).toList();
    }
  }
}
