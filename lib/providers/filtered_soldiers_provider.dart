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

  void filter(List<String> sections) {
    state = allSoldiers
        .where((element) => sections.contains(element.section))
        .toList();
  }
}
