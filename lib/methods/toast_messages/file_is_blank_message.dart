import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../widgets/my_toast.dart';

void fileIsBlankMessage(BuildContext context) {
  FToast toast = FToast();
  toast.context = context;
  toast.showToast(
    child: const MyToast(
      message: 'Please select a file to upload',
    ),
  );
}
