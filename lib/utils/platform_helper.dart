import 'dart:io';

import 'package:hymnal_app/constants/app_links.dart';

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
        return AppLinks.appStoreUrl;
      case AppPlatform.android:
        return AppLinks.playStoreUrl;
      case AppPlatform.unsupported:
        return AppLinks.playStoreUrl;
    }
  }

  static bool get canAutoOpenStore => currentPlatform != AppPlatform.unsupported;
}
