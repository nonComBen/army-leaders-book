import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart';

final notificationProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  NotificationAppLaunchDetails? _notificationAppLaunchDetails;
  bool _notificationsAllowed = false;

  NotificationAppLaunchDetails? launchDetails() {
    return _notificationAppLaunchDetails;
  }

  void setLaunchDetails(
      NotificationAppLaunchDetails? notificationAppLaunchDetails) {
    _notificationAppLaunchDetails = notificationAppLaunchDetails;
  }

  get isAllowed {
    return _notificationsAllowed;
  }

  Future<bool> requestPermission() async {
    if (_notificationsAllowed || Platform.isAndroid) {
      return true;
    }
    _notificationsAllowed = await notificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
        false;

    return _notificationsAllowed;
  }

  void scheduleNotification({
    required DateTime dateTime,
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    if (kIsWeb || !await requestPermission()) {
      debugPrint('Permission Denied');
      return;
    }
    final scheduledDate = TZDateTime.from(dateTime, local);
    debugPrint('Scheduled Date: $scheduledDate');

    try {
      notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'androidId',
            'androidName',
            channelDescription: 'Android Notification Channel',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } on Exception catch (e) {
      debugPrint('Notification Schedule Error: $e');
    }
  }

  void cancelPreviousNotifications(List<dynamic> ids) {
    for (int id in ids) {
      notificationsPlugin.cancel(id);
    }
  }
}
