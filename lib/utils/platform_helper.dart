import 'dart:io';

import 'package:hymnal_app/constants/app_constants.dart';

enum AppPlatform { ios, android, unsupported }

class PlatformHelper {
  static AppPlatform get currentPlatform {
    if (Platform.isIOS) return AppPlatform.ios;
    if (Platform.isAndroid) return AppPlatform.android;
    return AppPlatform.unsupported;
  }

  static String get storeUrl {
    switch (currentPlatform) {
      case AppPlatform.ios:
        return AppConstants.appStoreUrl;
      case AppPlatform.android:
        return AppConstants.playStoreUrl;
      case AppPlatform.unsupported:
        return AppConstants.playStoreUrl;
    }
  }

  static bool get canAutoOpenStore => currentPlatform != AppPlatform.unsupported;
}
