import 'package:flutter/foundation.dart';

class AppConfig {
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'http://10.0.2.2:8000');
  static const testKey = String.fromEnvironment('REVENUECAT_TEST_KEY');
  static const androidKey = String.fromEnvironment('REVENUECAT_ANDROID_KEY');
  static const iosKey = String.fromEnvironment('REVENUECAT_IOS_KEY');
  static const entitlement = 'taskpilot_pro';
  static const freeLimit = 3;
  static bool get supportedPurchases =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  static String get revenueCatKey => testKey.isNotEmpty
      ? testKey
      : (defaultTargetPlatform == TargetPlatform.iOS ? iosKey : androidKey);
}
