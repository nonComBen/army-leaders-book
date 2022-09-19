// ignore_for_file: file_names

int getRankSort(String rank) {
  int rankSort = 50;
  switch (rank.toUpperCase().trim()) {
    case 'PVT':
      rankSort = 0;
      break;
    case 'PV2':
      rankSort = 1;
      break;
    case 'PFC':
      rankSort = 2;
      break;
    case 'SPC':
      rankSort = 3;
      break;
    case 'CPL':
      rankSort = 4;
      break;
    case 'SGT':
      rankSort = 5;
      break;
    case 'SSG':
      rankSort = 6;
      break;
    case 'SFC':
      rankSort = 7;
      break;
    case 'MSG':
      rankSort = 8;
      break;
    case '1SG':
      rankSort = 9;
      break;
    case 'SGM':
      rankSort = 10;
      break;
    case 'CSM':
      rankSort = 11;
      break;
    case 'SMA':
      rankSort = 12;
      break;
    case 'WO1':
      rankSort = 13;
      break;
    case 'CW2':
      rankSort = 14;
      break;
    case 'CW3':
      rankSort = 15;
      break;
    case 'CW4':
      rankSort = 16;
      break;
    case 'CW5':
      rankSort = 17;
      break;
    case '2LT':
      rankSort = 18;
      break;
    case '1LT':
      rankSort = 19;
      break;
    case 'CPT':
      rankSort = 20;
      break;
    case 'MAJ':
      rankSort = 21;
      break;
    case 'LTC':
      rankSort = 22;
      break;
    case 'COL':
      rankSort = 23;
      break;
    case 'BG':
      rankSort = 24;
      break;
    case 'MG':
      rankSort = 25;
      break;
    case 'LTG':
      rankSort = 26;
      break;
    case 'GEN':
      rankSort = 27;
      break;
    default:
      rankSort = 50;
      break;
  }
  return rankSort;
}
