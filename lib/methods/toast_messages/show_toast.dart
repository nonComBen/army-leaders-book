import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../widgets/my_toast.dart';

void showToast(BuildContext context, String message) {
  FToast toast = FToast();
  toast.context = context;
  toast.showToast(
    child: MyToast(
      message: message,
    ),
  );
}
