import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('th'),
    Locale('tr'),
    Locale('vi'),
    Locale('zh'),
    Locale('zh', 'TW'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ko, this message translates to:
  /// **'Cinefy'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In ko, this message translates to:
  /// **'홈'**
  String get home;

  /// No description provided for @explore.
  ///
  /// In ko, this message translates to:
  /// **'탐색'**
  String get explore;

  /// No description provided for @search.
  ///
  /// In ko, this message translates to:
  /// **'검색'**
  String get search;

  /// No description provided for @library.
  ///
  /// In ko, this message translates to:
  /// **'보관함'**
  String get library;

  /// No description provided for @nowPlaying.
  ///
  /// In ko, this message translates to:
  /// **'현재 상영 중'**
  String get nowPlaying;

  /// No description provided for @popular.
  ///
  /// In ko, this message translates to:
  /// **'인기 영화'**
  String get popular;

  /// No description provided for @topRated.
  ///
  /// In ko, this message translates to:
  /// **'높은 평점'**
  String get topRated;

  /// No description provided for @upcoming.
  ///
  /// In ko, this message translates to:
  /// **'개봉 예정'**
  String get upcoming;

  /// No description provided for @seeAll.
  ///
  /// In ko, this message translates to:
  /// **'전체 보기'**
  String get seeAll;

  /// No description provided for @overview.
  ///
  /// In ko, this message translates to:
  /// **'줄거리'**
  String get overview;

  /// No description provided for @cast.
  ///
  /// In ko, this message translates to:
  /// **'출연진'**
  String get cast;

  /// No description provided for @similarMovies.
  ///
  /// In ko, this message translates to:
  /// **'비슷한 영화'**
  String get similarMovies;

  /// No description provided for @trailer.
  ///
  /// In ko, this message translates to:
  /// **'예고편'**
  String get trailer;

  /// No description provided for @searchHint.
  ///
  /// In ko, this message translates to:
  /// **'영화, 프로그램 검색'**
  String get searchHint;

  /// No description provided for @searchMovies.
  ///
  /// In ko, this message translates to:
  /// **'영화를 검색해보세요'**
  String get searchMovies;

  /// No description provided for @noSearchResults.
  ///
  /// In ko, this message translates to:
  /// **'검색 결과가 없습니다'**
  String get noSearchResults;

  /// No description provided for @selectGenre.
  ///
  /// In ko, this message translates to:
  /// **'장르를 선택해주세요'**
  String get selectGenre;

  /// No description provided for @noMovies.
  ///
  /// In ko, this message translates to:
  /// **'영화가 없습니다'**
  String get noMovies;

  /// No description provided for @noSimilarMovies.
  ///
  /// In ko, this message translates to:
  /// **'비슷한 영화가 없습니다'**
  String get noSimilarMovies;

  /// No description provided for @emptyLibrary.
  ///
  /// In ko, this message translates to:
  /// **'저장한 콘텐츠가 없습니다'**
  String get emptyLibrary;

  /// No description provided for @emptyLibraryHint.
  ///
  /// In ko, this message translates to:
  /// **'마음에 드는 영화를 저장해보세요'**
  String get emptyLibraryHint;

  /// No description provided for @error.
  ///
  /// In ko, this message translates to:
  /// **'오류가 발생했습니다'**
  String get error;

  /// No description provided for @biography.
  ///
  /// In ko, this message translates to:
  /// **'소개'**
  String get biography;

  /// No description provided for @filmography.
  ///
  /// In ko, this message translates to:
  /// **'출연 작품'**
  String get filmography;

  /// No description provided for @noFilmography.
  ///
  /// In ko, this message translates to:
  /// **'출연 작품이 없습니다'**
  String get noFilmography;

  /// No description provided for @settings.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In ko, this message translates to:
  /// **'화면'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In ko, this message translates to:
  /// **'테마'**
  String get theme;

  /// No description provided for @systemTheme.
  ///
  /// In ko, this message translates to:
  /// **'시스템 설정'**
  String get systemTheme;

  /// No description provided for @lightTheme.
  ///
  /// In ko, this message translates to:
  /// **'라이트'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In ko, this message translates to:
  /// **'다크'**
  String get darkTheme;

  /// No description provided for @about.
  ///
  /// In ko, this message translates to:
  /// **'정보'**
  String get about;

  /// No description provided for @appVersion.
  ///
  /// In ko, this message translates to:
  /// **'앱 버전'**
  String get appVersion;

  /// No description provided for @tmdbAttribution.
  ///
  /// In ko, this message translates to:
  /// **'이 앱은 TMDB API를 사용하지만 TMDB가 보증하거나 인증한 것은 아닙니다.'**
  String get tmdbAttribution;

  /// No description provided for @whereToWatch.
  ///
  /// In ko, this message translates to:
  /// **'감상 방법'**
  String get whereToWatch;

  /// No description provided for @streaming.
  ///
  /// In ko, this message translates to:
  /// **'스트리밍'**
  String get streaming;

  /// No description provided for @rent.
  ///
  /// In ko, this message translates to:
  /// **'대여'**
  String get rent;

  /// No description provided for @buy.
  ///
  /// In ko, this message translates to:
  /// **'구매'**
  String get buy;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'id',
    'it',
    'ja',
    'ko',
    'pt',
    'ru',
    'th',
    'tr',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'th':
      return AppLocalizationsTh();
    case 'tr':
      return AppLocalizationsTr();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
