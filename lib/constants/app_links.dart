class AppLinks {
  static const String websiteUrl = 'https://gogoshift.com';
  static const String contactUrl = 'https://gogoshift.com/contact';
  static const String repositoryUrl = 'https://github.com/gogoshift/Hymnal-Flutter';
  static const String settingsUrl = 'https://isax5.github.io/hymnal/backend-data/v1/settings.json';
  static const String appStoreUrl = 'https://apps.apple.com/us/app/adventist-hymnal/id1153114394';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=net.ddns.HimnarioAdventistaSPA';

  static String getShareMessage(
    String selectedText,
    String sharedFromApp, {
    String? hymnNumber,
    String? hymnTitle,
  }) {
    return '''${hymnNumber != null && hymnTitle != null ? '#$hymnNumber - $hymnTitle\n\n' : ''}$selectedText
$sharedFromApp''';
  }
}
