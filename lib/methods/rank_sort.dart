int getRankSort(String rank) {
  int rankSort = 50;
  final ranks = {
    'PVT': 0,
    'PV2': 1,
    'PFC': 2,
    'SPC': 3,
    'CPL': 4,
    'SGT': 5,
    'SSG': 6,
    'SFC': 7,
    'MSG': 8,
    '1SG': 9,
    'SGM': 10,
    'CSM': 11,
    'SMA': 12,
    'WO1': 13,
    'CW2': 14,
    'CW3': 15,
    'CW4': 16,
    'CW5': 17,
    '2LT': 18,
    '1LT': 19,
    'CPT': 20,
    'MAJ': 21,
    'LTC': 22,
    'COL': 23,
    'BG': 24,
    'MG': 25,
    'LTG': 26,
    'GEN': 27,
  };
  if (ranks.keys.contains(rank)) {
    rankSort = ranks[rank]!;
  } else {
    rankSort = 50;
  }
  return rankSort;
}
