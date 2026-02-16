import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
    Locale('ru')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Hymnal'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @lists.
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get lists;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search hymns...'**
  String get searchHint;

  /// No description provided for @noHymnsFound.
  ///
  /// In en, this message translates to:
  /// **'No hymns found'**
  String get noHymnsFound;

  /// No description provided for @numeric.
  ///
  /// In en, this message translates to:
  /// **'Numeric'**
  String get numeric;

  /// No description provided for @alpha.
  ///
  /// In en, this message translates to:
  /// **'Alphabetic'**
  String get alpha;

  /// No description provided for @thematic.
  ///
  /// In en, this message translates to:
  /// **'Thematic'**
  String get thematic;

  /// No description provided for @selectedHymnal.
  ///
  /// In en, this message translates to:
  /// **'Selected Hymnal'**
  String get selectedHymnal;

  /// No description provided for @selectHymnal.
  ///
  /// In en, this message translates to:
  /// **'Select Hymnal'**
  String get selectHymnal;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the Hymnal App'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a hymnal to start browsing'**
  String get welcomeSubtitle;

  /// No description provided for @hymnNumber.
  ///
  /// In en, this message translates to:
  /// **'Hymn Number'**
  String get hymnNumber;

  /// No description provided for @enterHymnNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter hymn number'**
  String get enterHymnNumber;

  /// No description provided for @openHymn.
  ///
  /// In en, this message translates to:
  /// **'Open Hymn'**
  String get openHymn;

  /// No description provided for @go.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get go;

  /// No description provided for @invalidHymnNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid hymn number'**
  String get invalidHymnNumber;

  /// No description provided for @hymnNotFound.
  ///
  /// In en, this message translates to:
  /// **'Hymn not found'**
  String get hymnNotFound;

  /// No description provided for @hymnalNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected hymnal is null'**
  String get hymnalNotSelected;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// No description provided for @clearHistoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear your history? This cannot be undone.'**
  String get clearHistoryConfirm;

  /// No description provided for @historyCleared.
  ///
  /// In en, this message translates to:
  /// **'History cleared'**
  String get historyCleared;

  /// No description provided for @clearFavorites.
  ///
  /// In en, this message translates to:
  /// **'Clear Favorites'**
  String get clearFavorites;

  /// No description provided for @clearFavoritesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all favorites? This cannot be undone.'**
  String get clearFavoritesConfirm;

  /// No description provided for @favoritesCleared.
  ///
  /// In en, this message translates to:
  /// **'Favorites cleared'**
  String get favoritesCleared;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavoritesYet;

  /// No description provided for @addHymnsToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add hymns to your favorites from the hymn page'**
  String get addHymnsToFavorites;

  /// No description provided for @noHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get noHistoryYet;

  /// No description provided for @removeFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{title}\" from favorites?'**
  String removeFavorite(String title);

  /// No description provided for @removeFavoriteTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Favorite'**
  String get removeFavoriteTitle;

  /// No description provided for @removedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'{title} removed from favorites'**
  String removedFromFavorites(String title);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @actionReversed.
  ///
  /// In en, this message translates to:
  /// **'Action reversed'**
  String get actionReversed;

  /// No description provided for @hymnRange.
  ///
  /// In en, this message translates to:
  /// **'Hymns {start}-{end}'**
  String hymnRange(int start, int end);

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @backgroundImage.
  ///
  /// In en, this message translates to:
  /// **'Background Image'**
  String get backgroundImage;

  /// No description provided for @showBackgroundImage.
  ///
  /// In en, this message translates to:
  /// **'Show background image'**
  String get showBackgroundImage;

  /// No description provided for @playback.
  ///
  /// In en, this message translates to:
  /// **'Playback'**
  String get playback;

  /// No description provided for @keepScreenOn.
  ///
  /// In en, this message translates to:
  /// **'Keep Screen On'**
  String get keepScreenOn;

  /// No description provided for @keepScreenOnDesc.
  ///
  /// In en, this message translates to:
  /// **'Don\'t dim or turn off screen'**
  String get keepScreenOnDesc;

  /// No description provided for @continuousPlay.
  ///
  /// In en, this message translates to:
  /// **'Continuous Play'**
  String get continuousPlay;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @clearHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Remove all recently viewed hymns'**
  String get clearHistoryDesc;

  /// No description provided for @clearFavoritesDesc.
  ///
  /// In en, this message translates to:
  /// **'Remove all favorite hymns'**
  String get clearFavoritesDesc;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @contribute.
  ///
  /// In en, this message translates to:
  /// **'Contribute'**
  String get contribute;

  /// No description provided for @repository.
  ///
  /// In en, this message translates to:
  /// **'GitHub Repository'**
  String get repository;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate the App'**
  String get rateApp;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// No description provided for @sheetMusicTitle.
  ///
  /// In en, this message translates to:
  /// **'Sheet Music - Hymn {number}'**
  String sheetMusicTitle(int number);

  /// No description provided for @failedToLoadImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image: {error}'**
  String failedToLoadImage(String error);

  /// No description provided for @noSheetMusicAvailable.
  ///
  /// In en, this message translates to:
  /// **'No sheet music available for this hymnal'**
  String get noSheetMusicAvailable;

  /// No description provided for @noSheetMusicFound.
  ///
  /// In en, this message translates to:
  /// **'No sheet music found for hymn {number}'**
  String noSheetMusicFound(int number);

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @viewLyrics.
  ///
  /// In en, this message translates to:
  /// **'View Lyrics'**
  String get viewLyrics;

  /// No description provided for @instrumental.
  ///
  /// In en, this message translates to:
  /// **'Instrumental'**
  String get instrumental;

  /// No description provided for @sung.
  ///
  /// In en, this message translates to:
  /// **'Sung'**
  String get sung;

  /// No description provided for @hymnalLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get hymnalLanguage;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @hymnTitle.
  ///
  /// In en, this message translates to:
  /// **'Hymn {number}'**
  String hymnTitle(int number);

  /// No description provided for @sharedFromApp.
  ///
  /// In en, this message translates to:
  /// **'Shared from Hymnal App'**
  String get sharedFromApp;

  /// No description provided for @nowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Now Playing'**
  String get nowPlaying;

  /// No description provided for @noAudioPlaying.
  ///
  /// In en, this message translates to:
  /// **'No audio playing'**
  String get noAudioPlaying;

  /// No description provided for @sectionHymnal.
  ///
  /// In en, this message translates to:
  /// **'Hymnal'**
  String get sectionHymnal;

  /// No description provided for @sectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get sectionAppearance;

  /// No description provided for @sectionBehavior.
  ///
  /// In en, this message translates to:
  /// **'Behavior'**
  String get sectionBehavior;

  /// No description provided for @sectionDataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get sectionDataManagement;

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get sectionAbout;

  /// No description provided for @backgroundImageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show background image on screens'**
  String get backgroundImageSubtitle;

  /// No description provided for @clearHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remove all recently viewed hymns'**
  String get clearHistorySubtitle;

  /// No description provided for @clearFavoritesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remove all favorite hymns'**
  String get clearFavoritesSubtitle;

  /// No description provided for @githubRepo.
  ///
  /// In en, this message translates to:
  /// **'GitHub Repository'**
  String get githubRepo;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
