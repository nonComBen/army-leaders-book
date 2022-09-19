import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrackingProvider with ChangeNotifier {
  bool _trackingAllowed = false;
  final SharedPreferences prefs;
  TrackingProvider(this.prefs) {
    final trackingAllowed = prefs.getBool('trackingAllowed') ?? true;
    _trackingAllowed = trackingAllowed;
  }

  bool get trackingAllowed {
    return _trackingAllowed;
  }

  void allowTracking() {
    _trackingAllowed = true;
    notifyListeners();
  }

  void disallowTracking() {
    _trackingAllowed = false;
    notifyListeners();
  }

  Future<bool> getTrackingFromPermission() async {
    PermissionStatus status = await Permission.appTrackingTransparency.status;
    if (status.isDenied) {
      status = await Permission.appTrackingTransparency.request();
    }
    return status.isGranted;
  }
}
