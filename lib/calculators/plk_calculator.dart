int getPlkScore(int time, int ageGroup, bool male) {
  if (male) {
    if (time > 340) return 100;
    if (time < 40) return 0;
    for (int i = 0; i < plkTable.length; i++) {
      if (plkTable[i][ageGroup * 2 - 1] <= time) {
        return plkTable[i][0];
      }
    }
    return 0;
  } else {
    if (time > 340) return 100;
    if (time < 40) return 0;
    for (int i = 0; i < plkTable.length; i++) {
      if (plkTable[i][ageGroup * 2] <= time) {
        return plkTable[i][0];
      }
    }
    return 0;
  }
}

List<List<int>> plkTable = [
  [
    100,
    0340,
    0340,
    0335,
    0335,
    0330,
    0330,
    0325,
    0325,
    0320,
    0320,
    0320,
    0320,
    0320,
    0320,
    0320,
    0320,
    0320,
    0320,
    0320,
    0320
  ],
  [
    99,
    0337,
    337,
    0332,
    332,
    0327,
    327,
    0322,
    322,
    0317,
    317,
    0317,
    317,
    0317,
    317,
    0317,
    317,
    0317,
    317,
    0317,
    317
  ],
  [
    98,
    0334,
    334,
    0329,
    329,
    0324,
    324,
    0319,
    319,
    0314,
    314,
    0314,
    314,
    0314,
    314,
    0314,
    314,
    0314,
    314,
    0314,
    314
  ],
  [
    97,
    0330,
    330,
    0325,
    325,
    0320,
    320,
    0315,
    315,
    0310,
    310,
    0310,
    310,
    0310,
    310,
    0310,
    310,
    0310,
    310,
    0310,
    310
  ],
  [
    96,
    0327,
    327,
    0322,
    322,
    0317,
    317,
    0312,
    312,
    0307,
    307,
    0307,
    307,
    0307,
    307,
    0307,
    307,
    0307,
    307,
    0307,
    307
  ],
  [
    95,
    0324,
    324,
    0319,
    319,
    0314,
    314,
    0309,
    309,
    0304,
    304,
    0304,
    304,
    0304,
    304,
    0304,
    304,
    0304,
    304,
    0304,
    304
  ],
  [
    94,
    0321,
    321,
    0316,
    316,
    0311,
    311,
    0306,
    306,
    0301,
    301,
    0301,
    301,
    0301,
    301,
    0301,
    301,
    0301,
    301,
    0301,
    301
  ],
  [
    93,
    0317,
    317,
    0312,
    312,
    0307,
    307,
    0302,
    302,
    0257,
    257,
    0257,
    257,
    0257,
    257,
    0257,
    257,
    0257,
    257,
    0257,
    257
  ],
  [
    92,
    0314,
    314,
    0309,
    309,
    0304,
    304,
    0259,
    259,
    0254,
    254,
    0254,
    254,
    0254,
    254,
    0254,
    254,
    0254,
    254,
    0254,
    254
  ],
  [
    91,
    0311,
    311,
    0306,
    306,
    0301,
    301,
    0256,
    256,
    0251,
    251,
    0251,
    251,
    0251,
    251,
    0251,
    251,
    0251,
    251,
    0251,
    251
  ],
  [
    90,
    0308,
    308,
    0303,
    303,
    0258,
    258,
    0253,
    253,
    0247,
    247,
    0247,
    247,
    0247,
    247,
    0247,
    247,
    0247,
    247,
    0247,
    247
  ],
  [
    89,
    0304,
    304,
    0259,
    259,
    0254,
    254,
    0249,
    249,
    0244,
    244,
    0244,
    244,
    0244,
    244,
    0244,
    244,
    0244,
    244,
    0244,
    244
  ],
  [
    88,
    0301,
    301,
    0256,
    256,
    0251,
    251,
    0246,
    246,
    0241,
    241,
    0241,
    241,
    0241,
    241,
    0241,
    241,
    0241,
    241,
    0241,
    241
  ],
  [
    87,
    0258,
    258,
    0253,
    253,
    0248,
    248,
    0243,
    243,
    0238,
    238,
    0238,
    238,
    0238,
    238,
    0238,
    238,
    0238,
    238,
    0238,
    238
  ],
  [
    86,
    0255,
    255,
    0250,
    250,
    0245,
    245,
    0240,
    240,
    0235,
    235,
    0235,
    235,
    0235,
    235,
    0235,
    235,
    0235,
    235,
    0235,
    235
  ],
  [
    85,
    0251,
    251,
    0246,
    246,
    0241,
    241,
    0236,
    236,
    0231,
    231,
    0231,
    231,
    0231,
    231,
    0231,
    231,
    0231,
    231,
    0231,
    231
  ],
  [
    84,
    0248,
    248,
    0243,
    243,
    0238,
    238,
    0233,
    233,
    0228,
    228,
    0228,
    228,
    0228,
    228,
    0228,
    228,
    0228,
    228,
    0228,
    228
  ],
  [
    83,
    0245,
    245,
    0240,
    240,
    0235,
    235,
    0230,
    230,
    0225,
    225,
    0225,
    225,
    0225,
    225,
    0225,
    225,
    0225,
    225,
    0225,
    225
  ],
  [
    82,
    0241,
    241,
    0237,
    237,
    0231,
    231,
    0227,
    227,
    0222,
    222,
    0222,
    222,
    0222,
    222,
    0222,
    222,
    0222,
    222,
    0222,
    222
  ],
  [
    81,
    0238,
    238,
    0233,
    233,
    0228,
    228,
    0223,
    223,
    0218,
    218,
    0218,
    218,
    0218,
    218,
    0218,
    218,
    0218,
    218,
    0218,
    218
  ],
  [
    80,
    0235,
    235,
    0230,
    230,
    0225,
    225,
    0220,
    220,
    0215,
    215,
    0215,
    215,
    0215,
    215,
    0215,
    215,
    0215,
    215,
    0215,
    215
  ],
  [
    79,
    0232,
    232,
    0227,
    227,
    0222,
    222,
    0217,
    217,
    0212,
    212,
    0212,
    212,
    0212,
    212,
    0212,
    212,
    0212,
    212,
    0212,
    212
  ],
  [
    78,
    0229,
    229,
    0223,
    223,
    0218,
    218,
    0213,
    213,
    0208,
    208,
    0208,
    208,
    0208,
    208,
    0208,
    208,
    0208,
    208,
    0208,
    208
  ],
  [
    77,
    0225,
    225,
    0220,
    220,
    0215,
    215,
    0210,
    210,
    0205,
    205,
    0205,
    205,
    0205,
    205,
    0205,
    205,
    0205,
    205,
    0205,
    205
  ],
  [
    76,
    0222,
    222,
    0217,
    217,
    0212,
    212,
    0207,
    207,
    0202,
    202,
    0202,
    202,
    0202,
    202,
    0202,
    202,
    0202,
    202,
    0202,
    202
  ],
  [
    75,
    0219,
    219,
    0214,
    214,
    0209,
    209,
    0204,
    204,
    0159,
    159,
    0159,
    159,
    0159,
    159,
    0159,
    159,
    0159,
    159,
    0159,
    159
  ],
  [
    74,
    0215,
    215,
    0210,
    210,
    0206,
    206,
    0200,
    200,
    0156,
    156,
    0156,
    156,
    0156,
    156,
    0156,
    156,
    0156,
    156,
    0156,
    156
  ],
  [
    73,
    0212,
    212,
    0207,
    207,
    0202,
    202,
    0157,
    157,
    0152,
    152,
    0152,
    152,
    0152,
    152,
    0152,
    152,
    0152,
    152,
    0152,
    152
  ],
  [
    72,
    0209,
    209,
    0204,
    204,
    0159,
    159,
    0154,
    154,
    0149,
    149,
    0149,
    149,
    0149,
    149,
    0149,
    149,
    0149,
    149,
    0149,
    149
  ],
  [
    71,
    0206,
    206,
    0201,
    201,
    0156,
    156,
    0151,
    151,
    0146,
    146,
    0146,
    146,
    0146,
    146,
    0146,
    146,
    0146,
    146,
    0146,
    146
  ],
  [
    70,
    0202,
    202,
    0158,
    158,
    0152,
    152,
    0147,
    147,
    0142,
    142,
    0142,
    142,
    0142,
    142,
    0142,
    142,
    0142,
    142,
    0142,
    142
  ],
  [
    69,
    0159,
    159,
    0154,
    154,
    0149,
    149,
    0144,
    144,
    0139,
    139,
    0139,
    139,
    0139,
    139,
    0139,
    139,
    0139,
    139,
    0139,
    139
  ],
  [
    68,
    0156,
    156,
    0151,
    151,
    0146,
    146,
    0141,
    141,
    0136,
    136,
    0136,
    136,
    0136,
    136,
    0136,
    136,
    0136,
    136,
    0136,
    136
  ],
  [
    67,
    0153,
    153,
    0148,
    148,
    0143,
    143,
    0138,
    138,
    0133,
    133,
    0133,
    133,
    0133,
    133,
    0133,
    133,
    0133,
    133,
    0133,
    133
  ],
  [
    66,
    0149,
    149,
    0145,
    145,
    0139,
    139,
    0135,
    135,
    0130,
    130,
    0130,
    130,
    0130,
    130,
    0130,
    130,
    0130,
    130,
    0130,
    130
  ],
  [
    65,
    0146,
    146,
    0141,
    141,
    0136,
    136,
    0131,
    131,
    0126,
    126,
    0126,
    126,
    0126,
    126,
    0126,
    126,
    0126,
    126,
    0126,
    126
  ],
  [
    64,
    0143,
    143,
    0138,
    138,
    0133,
    133,
    0128,
    128,
    0123,
    123,
    0123,
    123,
    0123,
    123,
    0123,
    123,
    0123,
    123,
    0123,
    123
  ],
  [
    63,
    0140,
    140,
    0135,
    135,
    0130,
    130,
    0125,
    125,
    0120,
    120,
    0120,
    120,
    0120,
    120,
    0120,
    120,
    0120,
    120,
    0120,
    120
  ],
  [
    62,
    0137,
    137,
    0132,
    132,
    0126,
    126,
    0122,
    122,
    0116,
    116,
    0116,
    116,
    0116,
    116,
    0116,
    116,
    0116,
    116,
    0116,
    116
  ],
  [
    61,
    0133,
    133,
    0128,
    128,
    0123,
    123,
    0118,
    118,
    0113,
    113,
    0113,
    113,
    0113,
    113,
    0113,
    113,
    0113,
    113,
    0113,
    113
  ],
  [
    60,
    0130,
    0130,
    0125,
    0125,
    0120,
    0120,
    0115,
    0115,
    0110,
    0110,
    0110,
    0110,
    0110,
    0110,
    0110,
    0110,
    0110,
    0110,
    0110,
    0110
  ],
  [
    59,
    0130,
    0130,
    0125,
    0125,
    0120,
    0120,
    0115,
    0115,
    0110,
    0110,
    0110,
    0110,
    0110,
    0110,
    0110,
    0110,
    0110,
    0110,
    0110,
    0110
  ],
  [
    58,
    0129,
    0129,
    0124,
    0124,
    0119,
    0119,
    0114,
    0114,
    0109,
    0109,
    0109,
    0109,
    0109,
    0109,
    0109,
    0109,
    0109,
    0109,
    0109,
    0109
  ],
  [
    57,
    0129,
    0129,
    0124,
    0124,
    0119,
    0119,
    0114,
    0114,
    0109,
    0109,
    0109,
    0109,
    0109,
    0109,
    0109,
    0109,
    0109,
    0109,
    0109,
    0109
  ],
  [
    56,
    0128,
    0128,
    0123,
    0123,
    0118,
    0118,
    0113,
    0113,
    0108,
    0108,
    0108,
    0108,
    0108,
    0108,
    0108,
    0108,
    0108,
    0108,
    0108,
    0108
  ],
  [
    55,
    0128,
    0128,
    0123,
    0123,
    0118,
    0118,
    0113,
    0113,
    0108,
    0108,
    0108,
    0108,
    0108,
    0108,
    0108,
    0108,
    0108,
    0108,
    0108,
    0108
  ],
  [
    54,
    0127,
    0127,
    0122,
    0122,
    0117,
    0117,
    0112,
    0112,
    0107,
    0107,
    0107,
    0107,
    0107,
    0107,
    0107,
    0107,
    0107,
    0107,
    0107,
    0107
  ],
  [
    53,
    0127,
    0127,
    0122,
    0122,
    0117,
    0117,
    0112,
    0112,
    0107,
    0107,
    0107,
    0107,
    0107,
    0107,
    0107,
    0107,
    0107,
    0107,
    0107,
    0107
  ],
  [
    52,
    0126,
    0126,
    0121,
    0121,
    0116,
    0116,
    0111,
    0111,
    0106,
    0106,
    0106,
    0106,
    0106,
    0106,
    0106,
    0106,
    0106,
    0106,
    0106,
    0106
  ],
  [
    51,
    0126,
    0126,
    0121,
    0121,
    0116,
    0116,
    0111,
    0111,
    0106,
    0106,
    0106,
    0106,
    0106,
    0106,
    0106,
    0106,
    0106,
    0106,
    0106,
    0106
  ],
  [
    50,
    0125,
    0125,
    0120,
    0120,
    0115,
    0115,
    0110,
    0110,
    0105,
    0105,
    0105,
    0105,
    0105,
    0105,
    0105,
    0105,
    0105,
    0105,
    0105,
    0105
  ],
  [
    49,
    0125,
    0125,
    0120,
    0120,
    0115,
    0115,
    0110,
    0110,
    0105,
    0105,
    0105,
    0105,
    0105,
    0105,
    0105,
    0105,
    0105,
    0105,
    0105,
    0105
  ],
  [
    48,
    0124,
    0124,
    0119,
    0119,
    0114,
    0114,
    0109,
    0109,
    0104,
    0104,
    0104,
    0104,
    0104,
    0104,
    0104,
    0104,
    0104,
    0104,
    0104,
    0104
  ],
  [
    47,
    0124,
    0124,
    0119,
    0119,
    0114,
    0114,
    0109,
    0109,
    0104,
    0104,
    0104,
    0104,
    0104,
    0104,
    0104,
    0104,
    0104,
    0104,
    0104,
    0104
  ],
  [
    46,
    0123,
    0123,
    0118,
    0118,
    0113,
    0113,
    0108,
    0108,
    0103,
    0103,
    0103,
    0103,
    0103,
    0103,
    0103,
    0103,
    0103,
    0103,
    0103,
    0103
  ],
  [
    45,
    0123,
    0123,
    0118,
    0118,
    0113,
    0113,
    0108,
    0108,
    0103,
    0103,
    0103,
    0103,
    0103,
    0103,
    0103,
    0103,
    0103,
    0103,
    0103,
    0103
  ],
  [
    44,
    0122,
    0122,
    0117,
    0117,
    0112,
    0112,
    0107,
    0107,
    0102,
    0102,
    0102,
    0102,
    0102,
    0102,
    0102,
    0102,
    0102,
    0102,
    0102,
    0102
  ],
  [
    43,
    0122,
    0122,
    0117,
    0117,
    0112,
    0112,
    0107,
    0107,
    0102,
    0102,
    0102,
    0102,
    0102,
    0102,
    0102,
    0102,
    0102,
    0102,
    0102,
    0102
  ],
  [
    42,
    0121,
    0121,
    0116,
    0116,
    0111,
    0111,
    0106,
    0106,
    0101,
    0101,
    0101,
    0101,
    0101,
    0101,
    0101,
    0101,
    0101,
    0101,
    0101,
    0101
  ],
  [
    41,
    0121,
    0121,
    0116,
    0116,
    0111,
    0111,
    0106,
    0106,
    0101,
    0101,
    0101,
    0101,
    0101,
    0101,
    0101,
    0101,
    0101,
    0101,
    0101,
    0101
  ],
  [
    40,
    0120,
    0120,
    0115,
    0115,
    0110,
    0110,
    0105,
    0105,
    0100,
    0100,
    0100,
    0100,
    0100,
    0100,
    0100,
    0100,
    0100,
    0100,
    0100,
    0100
  ],
  [
    39,
    0120,
    0120,
    0115,
    0115,
    0110,
    0110,
    0105,
    0105,
    0100,
    0100,
    0100,
    0100,
    0100,
    0100,
    0100,
    0100,
    0100,
    0100,
    0100,
    0100
  ],
  [
    38,
    0119,
    0119,
    0114,
    0114,
    0109,
    0109,
    0104,
    0104,
    0059,
    0059,
    0059,
    0059,
    0059,
    0059,
    0059,
    0059,
    0059,
    0059,
    0059,
    0059
  ],
  [
    37,
    0119,
    0119,
    0114,
    0114,
    0109,
    0109,
    0104,
    0104,
    0059,
    0059,
    0059,
    0059,
    0059,
    0059,
    0059,
    0059,
    0059,
    0059,
    0059,
    0059
  ],
  [
    36,
    0118,
    0118,
    0113,
    0113,
    0108,
    0108,
    0103,
    0103,
    0058,
    0058,
    0058,
    0058,
    0058,
    0058,
    0058,
    0058,
    0058,
    0058,
    0058,
    0058
  ],
  [
    35,
    0118,
    0118,
    0113,
    0113,
    0108,
    0108,
    0103,
    0103,
    0058,
    0058,
    0058,
    0058,
    0058,
    0058,
    0058,
    0058,
    0058,
    0058,
    0058,
    0058
  ],
  [
    34,
    0117,
    0117,
    0112,
    0112,
    0107,
    0107,
    0102,
    0102,
    0057,
    0057,
    0057,
    0057,
    0057,
    0057,
    0057,
    0057,
    0057,
    0057,
    0057,
    0057
  ],
  [
    33,
    0117,
    0117,
    0112,
    0112,
    0107,
    0107,
    0102,
    0102,
    0057,
    0057,
    0057,
    0057,
    0057,
    0057,
    0057,
    0057,
    0057,
    0057,
    0057,
    0057
  ],
  [
    32,
    0116,
    0116,
    0111,
    0111,
    0106,
    0106,
    0101,
    0101,
    0056,
    0056,
    0056,
    0056,
    0056,
    0056,
    0056,
    0056,
    0056,
    0056,
    0056,
    0056
  ],
  [
    31,
    0116,
    0116,
    0111,
    0111,
    0106,
    0106,
    0101,
    0101,
    0056,
    0056,
    0056,
    0056,
    0056,
    0056,
    0056,
    0056,
    0056,
    0056,
    0056,
    0056
  ],
  [
    30,
    0115,
    0115,
    0110,
    0110,
    0105,
    0105,
    0100,
    0100,
    0055,
    0055,
    0055,
    0055,
    0055,
    0055,
    0055,
    0055,
    0055,
    0055,
    0055,
    0055
  ],
  [
    29,
    0115,
    0115,
    0110,
    0110,
    0105,
    0105,
    0100,
    0100,
    0055,
    0055,
    0055,
    0055,
    0055,
    0055,
    0055,
    0055,
    0055,
    0055,
    0055,
    0055
  ],
  [
    28,
    0114,
    0114,
    0109,
    0109,
    0104,
    0104,
    0059,
    0059,
    0054,
    0054,
    0054,
    0054,
    0054,
    0054,
    0054,
    0054,
    0054,
    0054,
    0054,
    0054
  ],
  [
    27,
    0114,
    0114,
    0109,
    0109,
    0104,
    0104,
    0059,
    0059,
    0054,
    0054,
    0054,
    0054,
    0054,
    0054,
    0054,
    0054,
    0054,
    0054,
    0054,
    0054
  ],
  [
    26,
    0113,
    0113,
    0108,
    0108,
    0103,
    0103,
    0058,
    0058,
    0053,
    0053,
    0053,
    0053,
    0053,
    0053,
    0053,
    0053,
    0053,
    0053,
    0053,
    0053
  ],
  [
    25,
    0113,
    0113,
    0108,
    0108,
    0103,
    0103,
    0058,
    0058,
    0053,
    0053,
    0053,
    0053,
    0053,
    0053,
    0053,
    0053,
    0053,
    0053,
    0053,
    0053
  ],
  [
    24,
    0112,
    0112,
    0107,
    0107,
    0102,
    0102,
    0057,
    0057,
    0052,
    0052,
    0052,
    0052,
    0052,
    0052,
    0052,
    0052,
    0052,
    0052,
    0052,
    0052
  ],
  [
    23,
    0112,
    0112,
    0107,
    0107,
    0102,
    0102,
    0057,
    0057,
    0052,
    0052,
    0052,
    0052,
    0052,
    0052,
    0052,
    0052,
    0052,
    0052,
    0052,
    0052
  ],
  [
    22,
    0111,
    0111,
    0106,
    0106,
    0101,
    0101,
    0056,
    0056,
    0051,
    0051,
    0051,
    0051,
    0051,
    0051,
    0051,
    0051,
    0051,
    0051,
    0051,
    0051
  ],
  [
    21,
    0111,
    0111,
    0106,
    0106,
    0101,
    0101,
    0056,
    0056,
    0051,
    0051,
    0051,
    0051,
    0051,
    0051,
    0051,
    0051,
    0051,
    0051,
    0051,
    0051
  ],
  [
    20,
    0110,
    0110,
    0105,
    0105,
    0100,
    0100,
    0055,
    0055,
    0050,
    0050,
    0050,
    0050,
    0050,
    0050,
    0050,
    0050,
    0050,
    0050,
    0050,
    0050
  ],
  [
    19,
    0110,
    0110,
    0105,
    0105,
    0100,
    0100,
    0055,
    0055,
    0050,
    0050,
    0050,
    0050,
    0050,
    0050,
    0050,
    0050,
    0050,
    0050,
    0050,
    0050
  ],
  [
    18,
    0109,
    0109,
    0104,
    0104,
    0059,
    0059,
    0054,
    0054,
    0049,
    0049,
    0049,
    0049,
    0049,
    0049,
    0049,
    0049,
    0049,
    0049,
    0049,
    0049
  ],
  [
    17,
    0109,
    0109,
    0104,
    0104,
    0059,
    0059,
    0054,
    0054,
    0049,
    0049,
    0049,
    0049,
    0049,
    0049,
    0049,
    0049,
    0049,
    0049,
    0049,
    0049
  ],
  [
    16,
    0108,
    0108,
    0103,
    0103,
    0058,
    0058,
    0053,
    0053,
    0048,
    0048,
    0048,
    0048,
    0048,
    0048,
    0048,
    0048,
    0048,
    0048,
    0048,
    0048
  ],
  [
    15,
    0108,
    0108,
    0103,
    0103,
    0058,
    0058,
    0053,
    0053,
    0048,
    0048,
    0048,
    0048,
    0048,
    0048,
    0048,
    0048,
    0048,
    0048,
    0048,
    0048
  ],
  [
    14,
    0107,
    0107,
    0102,
    0102,
    0057,
    0057,
    0052,
    0052,
    0047,
    0047,
    0047,
    0047,
    0047,
    0047,
    0047,
    0047,
    0047,
    0047,
    0047,
    0047
  ],
  [
    13,
    0107,
    0107,
    0102,
    0102,
    0057,
    0057,
    0052,
    0052,
    0047,
    0047,
    0047,
    0047,
    0047,
    0047,
    0047,
    0047,
    0047,
    0047,
    0047,
    0047
  ],
  [
    12,
    0106,
    0106,
    0101,
    0101,
    0056,
    0056,
    0051,
    0051,
    0046,
    0046,
    0046,
    0046,
    0046,
    0046,
    0046,
    0046,
    0046,
    0046,
    0046,
    0046
  ],
  [
    11,
    0106,
    0106,
    0101,
    0101,
    0056,
    0056,
    0051,
    0051,
    0046,
    0046,
    0046,
    0046,
    0046,
    0046,
    0046,
    0046,
    0046,
    0046,
    0046,
    0046
  ],
  [
    10,
    0105,
    0105,
    0100,
    0100,
    0055,
    0055,
    0050,
    0050,
    0045,
    0045,
    0045,
    0045,
    0045,
    0045,
    0045,
    0045,
    0045,
    0045,
    0045,
    0045
  ],
  [
    9,
    0105,
    0105,
    0100,
    0100,
    0055,
    0055,
    0050,
    0050,
    0045,
    0045,
    0045,
    0045,
    0045,
    0045,
    0045,
    0045,
    0045,
    0045,
    0045,
    0045
  ],
  [
    8,
    0104,
    0104,
    0059,
    0059,
    0054,
    0054,
    0049,
    0049,
    0044,
    0044,
    0044,
    0044,
    0044,
    0044,
    0044,
    0044,
    0044,
    0044,
    0044,
    0044
  ],
  [
    7,
    0104,
    0104,
    0059,
    0059,
    0054,
    0054,
    0049,
    0049,
    0044,
    0044,
    0044,
    0044,
    0044,
    0044,
    0044,
    0044,
    0044,
    0044,
    0044,
    0044
  ],
  [
    6,
    0103,
    0103,
    0058,
    0058,
    0053,
    0053,
    0048,
    0048,
    0043,
    0043,
    0043,
    0043,
    0043,
    0043,
    0043,
    0043,
    0043,
    0043,
    0043,
    0043
  ],
  [
    5,
    0103,
    0103,
    0058,
    0058,
    0053,
    0053,
    0048,
    0048,
    0043,
    0043,
    0043,
    0043,
    0043,
    0043,
    0043,
    0043,
    0043,
    0043,
    0043,
    0043
  ],
  [
    4,
    0102,
    0102,
    0057,
    0057,
    0052,
    0052,
    0047,
    0047,
    0042,
    0042,
    0042,
    0042,
    0042,
    0042,
    0042,
    0042,
    0042,
    0042,
    0042,
    0042
  ],
  [
    3,
    0102,
    0102,
    0057,
    0057,
    0052,
    0052,
    0047,
    0047,
    0042,
    0042,
    0042,
    0042,
    0042,
    0042,
    0042,
    0042,
    0042,
    0042,
    0042,
    0042
  ],
  [
    2,
    0101,
    0101,
    0056,
    0056,
    0051,
    0051,
    0046,
    0046,
    0041,
    0041,
    0041,
    0041,
    0041,
    0041,
    0041,
    0041,
    0041,
    0041,
    0041,
    0041
  ],
  [
    1,
    0101,
    0101,
    0056,
    0056,
    0051,
    0051,
    0046,
    0046,
    0041,
    0041,
    0041,
    0041,
    0041,
    0041,
    0041,
    0041,
    0041,
    0041,
    0041,
    0041
  ],
  [
    0,
    0100,
    0100,
    0055,
    0055,
    0050,
    0050,
    0045,
    0045,
    0040,
    0040,
    0040,
    0040,
    0040,
    0040,
    0040,
    0040,
    0040,
    0040,
    0040,
    0040
  ],
];
