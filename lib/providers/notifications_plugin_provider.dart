import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsPluginProvider with ChangeNotifier {
  FlutterLocalNotificationsPlugin? _notificationsPlugin;
  NotificationsPluginProvider() {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  FlutterLocalNotificationsPlugin? get notificationsPlugin {
    return _notificationsPlugin;
  }
}
