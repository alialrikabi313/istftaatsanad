import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class Observability {
  Observability._();

  static final analytics = FirebaseAnalytics.instance;
  static final crashlytics = FirebaseCrashlytics.instance;

  static Future<void> init() async {
    // Crashlytics لا يعمل على الويب
    if (!kIsWeb) {
      await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

      FlutterError.onError = crashlytics.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        crashlytics.recordError(error, stack, fatal: true);
        return true;
      };
    }

    await analytics.setAnalyticsCollectionEnabled(!kDebugMode);
  }

  static Future<void> logScreen(String name) =>
      analytics.logScreenView(screenName: name);
}
