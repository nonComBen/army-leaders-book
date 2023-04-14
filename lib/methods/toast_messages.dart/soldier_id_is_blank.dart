import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../widgets/my_toast.dart';

void soldierIdIsBlankMessage(BuildContext context) {
  FToast toast = FToast();
  toast.context = context;
  toast.showToast(
    child: const MyToast(
      message:
          'Soldier Id must not be blank. To get your Soldiers\' Ids, download their data from the Soldiers page.',
    ),
  );
}
