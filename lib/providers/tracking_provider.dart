import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaders_book/providers/shared_prefs_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

final trackingProvider = Provider<TrackingService>((ref) {
  return TrackingService(ref.read(sharedPreferencesProvider));
});

class TrackingService {
  bool _trackingAllowed = false;
  final SharedPreferences prefs;
  TrackingService(this.prefs) {
    bool? trackingAllowed = prefs.getBool('trackingAllowed');
    if (trackingAllowed != null) {
      _trackingAllowed = trackingAllowed;
    } else {
      getTrackingFromPermission();
    }
  }

  bool get trackingAllowed {
    return _trackingAllowed;
  }

  void allowTracking() {
    _trackingAllowed = true;
  }

  void disallowTracking() {
    _trackingAllowed = false;
  }

  Future<void> getTrackingFromPermission() async {
    PermissionStatus status = await Permission.appTrackingTransparency.status;
    if (status.isDenied) {
      status = await Permission.appTrackingTransparency.request();
    }
    _trackingAllowed = status.isGranted;
    prefs.setBool('trackingAllowed', status.isGranted);
  }
}
