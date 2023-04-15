import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class PlatformApp extends StatelessWidget {
  factory PlatformApp({
    required String title,
    required ThemeData themeData,
    Map<String, Widget Function(BuildContext)> routes =
        const <String, WidgetBuilder>{},
    Route<dynamic>? Function(RouteSettings)? onGenerateRoute,
    required Widget home,
  }) {
    if (kIsWeb || Platform.isAndroid) {
      return AndroidApp(
        title: title,
        themeData: themeData,
        routes: routes,
        onGenerateRoute: onGenerateRoute,
        home: home,
      );
    } else {
      final iosThemeData = CupertinoThemeData(
        brightness: themeData.brightness,
        primaryColor: themeData.colorScheme.primary,
        primaryContrastingColor: themeData.colorScheme.onPrimary,
        scaffoldBackgroundColor: themeData.scaffoldBackgroundColor,
        barBackgroundColor: themeData.dialogBackgroundColor,
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
              color: themeData.brightness == Brightness.light
                  ? Colors.black
                  : Colors.white),
          primaryColor: themeData.colorScheme.onPrimary,
          navTitleTextStyle: TextStyle(
            inherit: false,
            color: themeData.colorScheme.onPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      return IOSApp(
        title: title,
        themeData: iosThemeData,
        routes: routes,
        onGenerateRoute: onGenerateRoute,
        home: home,
      );
    }
  }
}

class AndroidApp extends StatelessWidget implements PlatformApp {
  const AndroidApp({
    super.key,
    required this.title,
    required this.themeData,
    this.routes = const <String, WidgetBuilder>{},
    this.onGenerateRoute,
    required this.home,
  });
  final String title;
  final ThemeData themeData;
  final Map<String, Widget Function(BuildContext)> routes;
  final Route<dynamic>? Function(RouteSettings)? onGenerateRoute;
  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: themeData,
      routes: routes,
      onGenerateRoute: onGenerateRoute,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)
      ],
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
      home: home,
      debugShowCheckedModeBanner: false,
    );
  }
}

class IOSApp extends StatelessWidget implements PlatformApp {
  const IOSApp({
    super.key,
    required this.title,
    required this.themeData,
    this.routes = const <String, WidgetBuilder>{},
    this.onGenerateRoute,
    required this.home,
  });
  final String title;
  final CupertinoThemeData themeData;
  final Map<String, Widget Function(BuildContext)> routes;
  final Route<dynamic>? Function(RouteSettings)? onGenerateRoute;
  final Widget home;

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: title,
      theme: themeData,
      routes: routes,
      onGenerateRoute: onGenerateRoute,
      home: home,
      debugShowCheckedModeBanner: false,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)
      ],
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
  }
}
