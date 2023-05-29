import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../pages/premium_page.dart';
import '../../widgets/my_toast.dart';

void uploadRequiresSub(BuildContext context) {
  FToast toast = FToast();
  toast.context = context;
  toast.showToast(
    toastDuration: const Duration(seconds: 5),
    child: MyToast(
      message: 'Uploading via Excel requires Premium Subscription.',
      buttonText: 'Subscribe',
      onPressed: () => Navigator.of(context, rootNavigator: true)
          .pushNamed(PremiumPage.routeName),
    ),
  );
}

void pdfRequiresSub(BuildContext context) {
  FToast toast = FToast();
  toast.context = context;
  toast.showToast(
    toastDuration: const Duration(seconds: 5),
    child: MyToast(
      message: 'Downloading to pdf file requires Premium Subscription.',
      buttonText: 'Subscribe',
      onPressed: () => Navigator.of(context, rootNavigator: true)
          .pushNamed(PremiumPage.routeName),
    ),
  );
}
