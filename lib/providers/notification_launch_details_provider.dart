import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationLaunchDetailsProvider =
    Provider<NotificationLaunchDetailsService>((ref) {
  return NotificationLaunchDetailsService();
});

class NotificationLaunchDetailsService {
  NotificationAppLaunchDetails? _notificationAppLaunchDetails;

  NotificationAppLaunchDetails? launchDetails() {
    return _notificationAppLaunchDetails;
  }

  void setLaunchDetails(
      NotificationAppLaunchDetails? notificationAppLaunchDetails) {
    _notificationAppLaunchDetails = notificationAppLaunchDetails;
  }
}
