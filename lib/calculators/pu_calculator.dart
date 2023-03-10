class PuCalculator {
  int getPuScore(bool male, int ageGroupIndex, int puRaw) {
    if (male) {
      if (puRaw < 1) return 0;
      if (puRaw > 76) return 100;
      return maleTable[puRaw - 1][ageGroupIndex];
    } else {
      if (puRaw < 1) return 0;
      if (puRaw > 49) return 100;
      return femaleTable[puRaw - 1][ageGroupIndex];
    }
  }

  List<int> getBenchmarks(bool male, int ageGroupIndex) {
    return benchmarks[male ? ageGroupIndex : ageGroupIndex + 10];
  }

  List<List<int>> benchmarks = [
    [42, 64, 71],
    [40, 66, 75],
    [39, 68, 77],
    [36, 65, 75],
    [34, 63, 73],
    [30, 57, 66],
    [25, 51, 59],
    [20, 47, 56],
    [18, 44, 53],
    [16, 42, 50],
    [19, 36, 42],
    [17, 39, 46],
    [17, 42, 50],
    [15, 38, 45],
    [13, 33, 40],
    [12, 31, 37],
    [10, 28, 34],
    [9, 26, 31],
    [8, 23, 28],
    [7, 21, 25]
  ];

  List<List<int>> maleTable = [
    [3, 15, 20, 24, 26, 0, 0, 0, 0, 0],
    [5, 17, 21, 25, 27, 0, 0, 0, 0, 0],
    [6, 18, 22, 26, 28, 0, 0, 0, 0, 0],
    [8, 19, 23, 27, 29, 0, 0, 0, 0, 0],
    [9, 20, 24, 28, 30, 32, 36, 43, 45, 47],
    [10, 21, 25, 29, 31, 33, 38, 44, 46, 48],
    [12, 22, 26, 30, 32, 34, 39, 46, 47, 49],
    [13, 23, 27, 31, 33, 36, 40, 47, 49, 51],
    [14, 25, 28, 32, 34, 37, 41, 48, 50, 52],
    [16, 26, 29, 33, 35, 38, 42, 49, 51, 53],
    [17, 27, 31, 34, 36, 39, 44, 50, 52, 54],
    [19, 28, 32, 35, 37, 40, 45, 51, 53, 55],
    [20, 29, 33, 36, 38, 41, 46, 52, 54, 56],
    [21, 30, 34, 37, 39, 42, 47, 53, 55, 58],
    [23, 31, 35, 38, 41, 43, 48, 54, 57, 59],
    [24, 33, 36, 39, 42, 44, 49, 56, 58, 60],
    [26, 34, 37, 41, 43, 46, 51, 57, 59, 61],
    [27, 35, 38, 42, 44, 47, 52, 58, 60, 62],
    [28, 36, 39, 43, 45, 48, 53, 59, 61, 64],
    [30, 37, 40, 44, 46, 49, 54, 60, 62, 65],
    [31, 38, 41, 45, 47, 50, 55, 61, 63, 66],
    [32, 39, 42, 46, 48, 51, 56, 62, 65, 67],
    [34, 41, 43, 47, 49, 52, 58, 63, 66, 68],
    [35, 42, 44, 48, 50, 53, 59, 64, 67, 69],
    [37, 43, 45, 49, 51, 54, 60, 66, 68, 71],
    [38, 44, 46, 50, 52, 56, 61, 67, 69, 72],
    [39, 45, 47, 51, 53, 57, 62, 68, 70, 73],
    [41, 46, 48, 52, 54, 58, 64, 69, 71, 74],
    [42, 47, 49, 53, 55, 59, 65, 70, 73, 75],
    [43, 49, 50, 54, 56, 60, 66, 71, 74, 76],
    [45, 50, 52, 55, 57, 61, 67, 72, 75, 78],
    [46, 51, 53, 56, 58, 62, 68, 73, 76, 79],
    [48, 52, 54, 57, 59, 63, 69, 74, 77, 80],
    [49, 53, 55, 58, 60, 64, 71, 76, 78, 81],
    [50, 54, 56, 59, 61, 66, 72, 77, 79, 82],
    [52, 55, 57, 60, 62, 67, 73, 78, 81, 84],
    [53, 57, 58, 61, 63, 68, 74, 79, 82, 85],
    [54, 58, 59, 62, 64, 69, 75, 80, 83, 86],
    [56, 59, 60, 63, 65, 70, 76, 81, 84, 87],
    [57, 60, 61, 64, 66, 71, 78, 82, 85, 88],
    [59, 61, 62, 65, 67, 72, 79, 83, 86, 89],
    [60, 62, 63, 66, 68, 73, 80, 84, 87, 91],
    [61, 63, 64, 67, 69, 74, 81, 86, 89, 92],
    [63, 65, 65, 68, 70, 76, 82, 87, 90, 93],
    [64, 66, 66, 69, 71, 77, 84, 88, 91, 94],
    [66, 67, 67, 70, 72, 78, 85, 89, 92, 95],
    [67, 68, 68, 71, 73, 79, 86, 90, 93, 96],
    [68, 69, 69, 72, 74, 80, 87, 91, 94, 98],
    [70, 70, 71, 73, 75, 81, 88, 92, 95, 99],
    [71, 71, 72, 74, 76, 82, 89, 93, 97, 100],
    [72, 73, 73, 75, 77, 83, 91, 94, 98, 100],
    [74, 74, 74, 76, 78, 84, 92, 96, 99, 100],
    [75, 75, 75, 77, 79, 86, 93, 97, 100, 100],
    [77, 76, 76, 78, 81, 87, 94, 98, 100, 100],
    [78, 77, 77, 79, 82, 88, 95, 99, 100, 100],
    [79, 78, 78, 81, 83, 89, 96, 100, 100, 100],
    [81, 79, 79, 82, 84, 90, 98, 100, 100, 100],
    [82, 81, 80, 83, 85, 91, 99, 100, 100, 100],
    [83, 82, 81, 84, 86, 92, 100, 100, 100, 100],
    [85, 83, 82, 85, 87, 93, 100, 100, 100, 100],
    [88, 84, 83, 86, 88, 94, 100, 100, 100, 100],
    [88, 85, 84, 87, 89, 96, 100, 100, 100, 100],
    [89, 86, 85, 88, 90, 97, 100, 100, 100, 100],
    [90, 87, 86, 89, 91, 98, 100, 100, 100, 100],
    [92, 89, 87, 90, 92, 99, 100, 100, 100, 100],
    [93, 90, 88, 91, 93, 100, 100, 100, 100, 100],
    [94, 91, 89, 92, 94, 100, 100, 100, 100, 100],
    [96, 92, 91, 93, 95, 100, 100, 100, 100, 100],
    [97, 93, 92, 94, 96, 100, 100, 100, 100, 100],
    [99, 94, 93, 95, 97, 100, 100, 100, 100, 100],
    [100, 96, 94, 96, 98, 100, 100, 100, 100, 100],
    [100, 97, 95, 97, 99, 100, 100, 100, 100, 100],
    [100, 98, 96, 98, 100, 100, 100, 100, 100, 100],
    [100, 99, 97, 99, 100, 100, 100, 100, 100, 100],
    [100, 100, 98, 100, 100, 100, 100, 100, 100, 100],
    [100, 100, 99, 100, 100, 100, 100, 100, 100, 100],
  ];

  List<List<int>> femaleTable = [
    [29, 38, 41, 41, 42, 0, 0, 0, 0, 0],
    [30, 39, 42, 43, 44, 0, 0, 0, 0, 0],
    [32, 41, 43, 44, 45, 0, 0, 0, 0, 0],
    [34, 42, 44, 45, 47, 0, 0, 0, 0, 0],
    [36, 43, 45, 47, 48, 49, 52, 53, 54, 56],
    [37, 45, 47, 48, 50, 50, 53, 55, 56, 58],
    [39, 46, 48, 49, 51, 52, 55, 56, 58, 60],
    [41, 48, 49, 49, 53, 54, 57, 58, 60, 62],
    [43, 49, 49, 50, 54, 55, 58, 60, 62, 64],
    [44, 49, 50, 52, 56, 57, 60, 62, 64, 67],
    [46, 50, 52, 54, 57, 58, 62, 64, 66, 69],
    [48, 52, 54, 56, 59, 60, 63, 65, 68, 71],
    [50, 54, 55, 58, 60, 62, 65, 67, 70, 73],
    [51, 56, 56, 59, 61, 63, 67, 69, 72, 76],
    [53, 57, 58, 60, 63, 65, 68, 71, 74, 78],
    [55, 59, 59, 61, 64, 66, 70, 73, 76, 80],
    [57, 60, 60, 63, 66, 68, 72, 75, 78, 82],
    [58, 61, 61, 64, 67, 70, 73, 76, 80, 84],
    [60, 63, 62, 65, 69, 71, 75, 78, 82, 87],
    [62, 64, 64, 67, 70, 73, 77, 80, 84, 89],
    [63, 66, 65, 68, 72, 74, 78, 82, 86, 91],
    [65, 67, 66, 69, 73, 76, 80, 84, 88, 93],
    [67, 68, 67, 71, 75, 78, 82, 85, 90, 96],
    [69, 70, 68, 72, 76, 79, 83, 87, 92, 98],
    [70, 71, 70, 73, 78, 81, 85, 89, 94, 100],
    [72, 72, 71, 75, 79, 82, 87, 91, 96, 100],
    [74, 74, 72, 76, 81, 84, 88, 93, 98, 100],
    [76, 75, 73, 77, 82, 86, 90, 95, 100, 100],
    [77, 77, 75, 79, 84, 87, 92, 96, 100, 100],
    [79, 78, 76, 80, 85, 89, 93, 98, 100, 100],
    [81, 79, 77, 81, 87, 90, 95, 100, 100, 100],
    [83, 81, 78, 83, 88, 92, 97, 100, 100, 100],
    [84, 82, 79, 84, 90, 94, 98, 100, 100, 100],
    [86, 83, 81, 85, 91, 95, 100, 100, 100, 100],
    [88, 85, 82, 87, 93, 97, 100, 100, 100, 100],
    [90, 86, 83, 88, 94, 98, 100, 100, 100, 100],
    [91, 88, 84, 89, 96, 100, 100, 100, 100, 100],
    [93, 89, 85, 91, 97, 100, 100, 100, 100, 100],
    [95, 90, 87, 92, 99, 100, 100, 100, 100, 100],
    [97, 92, 88, 93, 100, 100, 100, 100, 100, 100],
    [98, 93, 89, 95, 100, 100, 100, 100, 100, 100],
    [100, 94, 90, 96, 100, 100, 100, 100, 100, 100],
    [100, 96, 92, 97, 100, 100, 100, 100, 100, 100],
    [100, 97, 93, 99, 100, 100, 100, 100, 100, 100],
    [100, 99, 94, 100, 100, 100, 100, 100, 100, 100],
    [100, 100, 95, 100, 100, 100, 100, 100, 100, 100],
    [100, 100, 96, 100, 100, 100, 100, 100, 100, 100],
    [100, 100, 98, 100, 100, 100, 100, 100, 100, 100],
    [100, 100, 99, 100, 100, 100, 100, 100, 100, 100],
  ];
}
