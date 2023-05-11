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
    final trackingAllowed = prefs.getBool('trackingAllowed') ?? true;
    _trackingAllowed = trackingAllowed;
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

  Future<bool> getTrackingFromPermission() async {
    PermissionStatus status = await Permission.appTrackingTransparency.status;
    if (status.isDenied) {
      status = await Permission.appTrackingTransparency.request();
    }
    return status.isGranted;
  }
}
