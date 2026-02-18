class AppLinks {
  static const String appStoreUrl = 'https://apps.apple.com/us/app/adventist-hymnal/id1153114394';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=net.ddns.HimnarioAdventistaSPA';

  static String getShareMessage(String selectedText, String sharedFromApp) {
    return '''$selectedText
$sharedFromApp''';
  }
}
