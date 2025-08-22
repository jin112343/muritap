import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

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
    Locale('ja'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Impossible Tap'**
  String get appName;

  /// No description provided for @navigationRanking.
  ///
  /// In en, this message translates to:
  /// **'Ranking'**
  String get navigationRanking;

  /// No description provided for @navigationHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navigationHome;

  /// No description provided for @navigationSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navigationSettings;

  /// No description provided for @homeLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get homeLevel;

  /// No description provided for @homeTotalTaps.
  ///
  /// In en, this message translates to:
  /// **'Total Taps'**
  String get homeTotalTaps;

  /// No description provided for @homeTodayTaps.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Taps'**
  String get homeTodayTaps;

  /// No description provided for @homeTapButton.
  ///
  /// In en, this message translates to:
  /// **'TAP!'**
  String get homeTapButton;

  /// No description provided for @homeLevelUp.
  ///
  /// In en, this message translates to:
  /// **'Level Up!'**
  String get homeLevelUp;

  /// No description provided for @homeNewRecord.
  ///
  /// In en, this message translates to:
  /// **'New Record!'**
  String get homeNewRecord;

  /// No description provided for @homeAchievement.
  ///
  /// In en, this message translates to:
  /// **'Achievement Unlocked!'**
  String get homeAchievement;

  /// No description provided for @homeRatingDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'100 Taps Achieved!'**
  String get homeRatingDialogTitle;

  /// No description provided for @homeRatingDialogContent.
  ///
  /// In en, this message translates to:
  /// **'🎉 Congratulations! You\'ve achieved 100 taps!\n\nDid you enjoy this app?\nIf you liked it, could you give us a 5-star rating on the App Store?\n\nYour rating helps us improve the app.'**
  String get homeRatingDialogContent;

  /// No description provided for @homeRatingDialogLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get homeRatingDialogLater;

  /// No description provided for @homeRatingDialogRateOnAppStore.
  ///
  /// In en, this message translates to:
  /// **'Rate on App Store'**
  String get homeRatingDialogRateOnAppStore;

  /// No description provided for @rankingTitle.
  ///
  /// In en, this message translates to:
  /// **'Ranking'**
  String get rankingTitle;

  /// No description provided for @rankingSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In to Game Center'**
  String get rankingSignIn;

  /// No description provided for @rankingShowLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Show Leaderboard'**
  String get rankingShowLeaderboard;

  /// No description provided for @rankingInAppRanking.
  ///
  /// In en, this message translates to:
  /// **'In-App Ranking'**
  String get rankingInAppRanking;

  /// No description provided for @rankingShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get rankingShare;

  /// No description provided for @rankingShareText.
  ///
  /// In en, this message translates to:
  /// **'Achieved Level {level} with {taps} total taps in Impossible Tap!\nJoin the ranking too!\nDownload the app here (iOS):\nhttps://apps.apple.com/jp/developer/jin-mizoi/id1548623319'**
  String rankingShareText(Object level, Object taps);

  /// No description provided for @rankingNoData.
  ///
  /// In en, this message translates to:
  /// **'No ranking data available'**
  String get rankingNoData;

  /// No description provided for @rankingLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get rankingLoading;

  /// No description provided for @rankingError.
  ///
  /// In en, this message translates to:
  /// **'Error occurred'**
  String get rankingError;

  /// No description provided for @settingsTabsSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTabsSettings;

  /// No description provided for @settingsTabsStats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get settingsTabsStats;

  /// No description provided for @settingsTabsPurchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get settingsTabsPurchase;

  /// No description provided for @settingsGeneralTitle.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get settingsGeneralTitle;

  /// No description provided for @settingsGeneralDailyNotification.
  ///
  /// In en, this message translates to:
  /// **'Daily Notification (8 PM)'**
  String get settingsGeneralDailyNotification;

  /// No description provided for @settingsGeneralNotificationDescription.
  ///
  /// In en, this message translates to:
  /// **'Receive a daily reminder to play'**
  String get settingsGeneralNotificationDescription;

  /// No description provided for @settingsGeneralAppInfo.
  ///
  /// In en, this message translates to:
  /// **'App Information'**
  String get settingsGeneralAppInfo;

  /// No description provided for @settingsGeneralVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsGeneralVersion;

  /// No description provided for @settingsGeneralBuildNumber.
  ///
  /// In en, this message translates to:
  /// **'Build Number'**
  String get settingsGeneralBuildNumber;

  /// No description provided for @settingsGeneralDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get settingsGeneralDeveloper;

  /// No description provided for @settingsGeneralPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsGeneralPrivacyPolicy;

  /// No description provided for @settingsGeneralTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsGeneralTermsOfService;

  /// No description provided for @settingsStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get settingsStatsTitle;

  /// No description provided for @settingsStatsToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get settingsStatsToday;

  /// No description provided for @settingsStatsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get settingsStatsThisWeek;

  /// No description provided for @settingsStatsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get settingsStatsThisMonth;

  /// No description provided for @settingsStatsTotalTaps.
  ///
  /// In en, this message translates to:
  /// **'Total Taps'**
  String get settingsStatsTotalTaps;

  /// No description provided for @settingsStatsCurrentLevel.
  ///
  /// In en, this message translates to:
  /// **'Current Level'**
  String get settingsStatsCurrentLevel;

  /// No description provided for @settingsStatsAverageTapsPerDay.
  ///
  /// In en, this message translates to:
  /// **'Average Taps/Day'**
  String get settingsStatsAverageTapsPerDay;

  /// No description provided for @settingsStatsBestDay.
  ///
  /// In en, this message translates to:
  /// **'Best Day'**
  String get settingsStatsBestDay;

  /// No description provided for @settingsStatsStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get settingsStatsStreak;

  /// No description provided for @settingsPurchaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchase Items'**
  String get settingsPurchaseTitle;

  /// No description provided for @settingsPurchaseRemoveAds.
  ///
  /// In en, this message translates to:
  /// **'Remove Ads'**
  String get settingsPurchaseRemoveAds;

  /// No description provided for @settingsPurchaseRemoveAdsDescription.
  ///
  /// In en, this message translates to:
  /// **'Enjoy the game without advertisements'**
  String get settingsPurchaseRemoveAdsDescription;

  /// No description provided for @settingsPurchaseRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get settingsPurchaseRestore;

  /// No description provided for @settingsPurchasePurchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get settingsPurchasePurchase;

  /// No description provided for @settingsPurchasePurchased.
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get settingsPurchasePurchased;

  /// No description provided for @settingsPurchaseUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get settingsPurchaseUnavailable;

  /// No description provided for @settingsPurchaseLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get settingsPurchaseLoading;

  /// No description provided for @settingsPurchaseError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during purchase. Please try again later.'**
  String get settingsPurchaseError;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @commonSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get commonSuccess;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get commonRestore;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// No description provided for @commonWatch.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get commonWatch;

  /// No description provided for @commonUnderstand.
  ///
  /// In en, this message translates to:
  /// **'I understand'**
  String get commonUnderstand;

  /// No description provided for @commonRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get commonRestart;

  /// No description provided for @dialogsLevelSkipTitle.
  ///
  /// In en, this message translates to:
  /// **'Level Skip'**
  String get dialogsLevelSkipTitle;

  /// No description provided for @dialogsLevelSkipContent.
  ///
  /// In en, this message translates to:
  /// **'Skip to the next level? This will consume your skip tickets.'**
  String get dialogsLevelSkipContent;

  /// No description provided for @dialogsLevelSkipSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get dialogsLevelSkipSkip;

  /// No description provided for @dialogsLevelSkipCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogsLevelSkipCancel;

  /// No description provided for @dialogsLevelSkipSuccess.
  ///
  /// In en, this message translates to:
  /// **'Skipped to Level {level}!'**
  String dialogsLevelSkipSuccess(Object level);

  /// No description provided for @dialogsLevelSkipMaxLevel.
  ///
  /// In en, this message translates to:
  /// **'You have already reached the maximum level.'**
  String get dialogsLevelSkipMaxLevel;

  /// No description provided for @dialogsLevelSkipError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during skip process: {error}'**
  String dialogsLevelSkipError(Object error);

  /// No description provided for @dialogsDailyChallengeAlreadyCompleted.
  ///
  /// In en, this message translates to:
  /// **'Today\'s daily challenge is already completed. Please try again tomorrow!'**
  String get dialogsDailyChallengeAlreadyCompleted;

  /// No description provided for @dialogsDailyChallengeCompleted.
  ///
  /// In en, this message translates to:
  /// **'Daily challenge completed! You earned {reward} taps'**
  String dialogsDailyChallengeCompleted(Object reward);

  /// No description provided for @dialogsDailyChallengeNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Daily challenge is not available yet'**
  String get dialogsDailyChallengeNotAvailable;

  /// No description provided for @dialogsVideoAdTitle.
  ///
  /// In en, this message translates to:
  /// **'Video Advertisement'**
  String get dialogsVideoAdTitle;

  /// No description provided for @dialogsVideoAdContent.
  ///
  /// In en, this message translates to:
  /// **'Watch a video advertisement to earn rewards?\n\nAfter watching, you will earn 250 taps.'**
  String get dialogsVideoAdContent;

  /// No description provided for @dialogsVideoAdWatch.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get dialogsVideoAdWatch;

  /// No description provided for @dialogsVideoAdCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogsVideoAdCancel;

  /// No description provided for @dialogsVideoAdSuccess.
  ///
  /// In en, this message translates to:
  /// **'Video watching completed! You earned 250 taps'**
  String get dialogsVideoAdSuccess;

  /// No description provided for @dialogsVideoAdFailed.
  ///
  /// In en, this message translates to:
  /// **'Video watching failed. You could not earn rewards.'**
  String get dialogsVideoAdFailed;

  /// No description provided for @dialogsVideoAdSuccessWithError.
  ///
  /// In en, this message translates to:
  /// **'Video watching completed! You earned 250 taps (an error occurred but rewards were given)'**
  String get dialogsVideoAdSuccessWithError;

  /// No description provided for @dialogsVideoAdLoading.
  ///
  /// In en, this message translates to:
  /// **'Video advertisement is loading. Please wait and try again.'**
  String get dialogsVideoAdLoading;

  /// No description provided for @dialogsDataDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Data Deletion'**
  String get dialogsDataDeleteTitle;

  /// No description provided for @dialogsDataDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all data? This action cannot be undone.'**
  String get dialogsDataDeleteContent;

  /// No description provided for @dialogsDataDeleteDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get dialogsDataDeleteDelete;

  /// No description provided for @dialogsDataDeleteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogsDataDeleteCancel;

  /// No description provided for @dialogsDataDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'All data has been deleted'**
  String get dialogsDataDeleteSuccess;

  /// No description provided for @dialogsDataDeleteError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while deleting data: {error}'**
  String dialogsDataDeleteError(Object error);

  /// No description provided for @dialogsLanguageChangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Change language?'**
  String get dialogsLanguageChangeTitle;

  /// No description provided for @dialogsLanguageChangeContent.
  ///
  /// In en, this message translates to:
  /// **'You need to restart the app to change the language.'**
  String get dialogsLanguageChangeContent;

  /// No description provided for @dialogsLanguageChangeRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get dialogsLanguageChangeRestart;

  /// No description provided for @dialogsLanguageChangeCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogsLanguageChangeCancel;

  /// No description provided for @dialogsPurchaseSuccess.
  ///
  /// In en, this message translates to:
  /// **'{productName} purchased successfully!'**
  String dialogsPurchaseSuccess(Object productName);

  /// No description provided for @dialogsPurchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed. Please try again later.'**
  String get dialogsPurchaseFailed;

  /// No description provided for @dialogsPurchaseError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during purchase. Please try again later.'**
  String get dialogsPurchaseError;

  /// No description provided for @dialogsPurchaseRestoreStarted.
  ///
  /// In en, this message translates to:
  /// **'Purchase restoration started'**
  String get dialogsPurchaseRestoreStarted;

  /// No description provided for @dialogsPurchaseRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase restoration failed. Please try again later.'**
  String get dialogsPurchaseRestoreFailed;

  /// No description provided for @dialogsNotificationEnabled.
  ///
  /// In en, this message translates to:
  /// **'Daily 8 PM notification enabled'**
  String get dialogsNotificationEnabled;

  /// No description provided for @dialogsNotificationDisabled.
  ///
  /// In en, this message translates to:
  /// **'Daily 8 PM notification disabled'**
  String get dialogsNotificationDisabled;

  /// No description provided for @dialogsNotificationError.
  ///
  /// In en, this message translates to:
  /// **'Notification setting error: {error}'**
  String dialogsNotificationError(Object error);

  /// No description provided for @dialogsEmailError.
  ///
  /// In en, this message translates to:
  /// **'Could not open email app'**
  String get dialogsEmailError;

  /// No description provided for @dialogsEmailSendError.
  ///
  /// In en, this message translates to:
  /// **'Email sending error: {error}'**
  String dialogsEmailSendError(Object error);

  /// No description provided for @dialogsScoreSubmitSuccess.
  ///
  /// In en, this message translates to:
  /// **'Score {score} submitted successfully!'**
  String dialogsScoreSubmitSuccess(Object score);

  /// No description provided for @dialogsScoreSubmitFailed.
  ///
  /// In en, this message translates to:
  /// **'Score submission failed'**
  String get dialogsScoreSubmitFailed;

  /// No description provided for @titlesTutorial.
  ///
  /// In en, this message translates to:
  /// **'Tutorial'**
  String get titlesTutorial;

  /// No description provided for @titlesAchievement.
  ///
  /// In en, this message translates to:
  /// **'Achievement'**
  String get titlesAchievement;

  /// No description provided for @titlesDailyChallenge.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge'**
  String get titlesDailyChallenge;

  /// No description provided for @titlesLevelUp.
  ///
  /// In en, this message translates to:
  /// **'Level Up!'**
  String get titlesLevelUp;

  /// No description provided for @titlesNewRecord.
  ///
  /// In en, this message translates to:
  /// **'New Record!'**
  String get titlesNewRecord;

  /// No description provided for @titlesAchievementUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Achievement Unlocked!'**
  String get titlesAchievementUnlocked;

  /// No description provided for @statsToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get statsToday;

  /// No description provided for @statsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get statsThisWeek;

  /// No description provided for @statsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get statsThisMonth;

  /// No description provided for @statsTotalTaps.
  ///
  /// In en, this message translates to:
  /// **'Total Taps'**
  String get statsTotalTaps;

  /// No description provided for @statsCurrentLevel.
  ///
  /// In en, this message translates to:
  /// **'Current Level'**
  String get statsCurrentLevel;

  /// No description provided for @statsAverageTapsPerDay.
  ///
  /// In en, this message translates to:
  /// **'Average Taps/Day'**
  String get statsAverageTapsPerDay;

  /// No description provided for @statsBestDay.
  ///
  /// In en, this message translates to:
  /// **'Best Day'**
  String get statsBestDay;

  /// No description provided for @statsStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get statsStreak;

  /// No description provided for @statsTaps.
  ///
  /// In en, this message translates to:
  /// **'Taps'**
  String get statsTaps;

  /// No description provided for @statsLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get statsLevel;

  /// No description provided for @statsDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get statsDate;

  /// No description provided for @statsNoData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get statsNoData;

  /// No description provided for @supportContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get supportContact;

  /// No description provided for @supportContactDescription.
  ///
  /// In en, this message translates to:
  /// **'Bug reports and feature requests'**
  String get supportContactDescription;

  /// No description provided for @supportPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get supportPrivacyPolicy;

  /// No description provided for @supportPrivacyDescription.
  ///
  /// In en, this message translates to:
  /// **'Personal information handling'**
  String get supportPrivacyDescription;

  /// No description provided for @supportTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get supportTermsOfService;

  /// No description provided for @supportTermsDescription.
  ///
  /// In en, this message translates to:
  /// **'App usage conditions'**
  String get supportTermsDescription;

  /// No description provided for @appInfoAppInformation.
  ///
  /// In en, this message translates to:
  /// **'App Information'**
  String get appInfoAppInformation;

  /// No description provided for @appInfoCurrentLevel.
  ///
  /// In en, this message translates to:
  /// **'Current Level'**
  String get appInfoCurrentLevel;

  /// No description provided for @appInfoCurrentTapMultiplier.
  ///
  /// In en, this message translates to:
  /// **'Current Tap Multiplier'**
  String get appInfoCurrentTapMultiplier;

  /// No description provided for @appInfoVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get appInfoVersion;

  /// No description provided for @appInfoBuildNumber.
  ///
  /// In en, this message translates to:
  /// **'Build Number'**
  String get appInfoBuildNumber;

  /// No description provided for @appInfoDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get appInfoDeveloper;

  /// No description provided for @dataManagementDataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagementDataManagement;

  /// No description provided for @dataManagementDeleteData.
  ///
  /// In en, this message translates to:
  /// **'Delete Data'**
  String get dataManagementDeleteData;

  /// No description provided for @dataManagementDeleteDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Reset all data'**
  String get dataManagementDeleteDataDescription;

  /// No description provided for @dataManagementDeleteDataConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all data? This action cannot be undone.'**
  String get dataManagementDeleteDataConfirm;

  /// No description provided for @notificationsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsNotifications;

  /// No description provided for @notificationsDailyNotification.
  ///
  /// In en, this message translates to:
  /// **'Daily 8 PM Notification'**
  String get notificationsDailyNotification;

  /// No description provided for @notificationsDailyNotificationDescription.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder to tap at 8 PM'**
  String get notificationsDailyNotificationDescription;

  /// No description provided for @purchasePurchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get purchasePurchase;

  /// No description provided for @purchaseRemoveAds.
  ///
  /// In en, this message translates to:
  /// **'Remove Banner Ads'**
  String get purchaseRemoveAds;

  /// No description provided for @purchaseRemoveAdsDescription.
  ///
  /// In en, this message translates to:
  /// **'Hide banner ads only.\n(Video ads remain available)'**
  String get purchaseRemoveAdsDescription;

  /// No description provided for @purchaseRestorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get purchaseRestorePurchases;

  /// No description provided for @purchaseRestorePurchasesDescription.
  ///
  /// In en, this message translates to:
  /// **'Restore previous purchases'**
  String get purchaseRestorePurchasesDescription;

  /// No description provided for @purchasePurchased.
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get purchasePurchased;

  /// No description provided for @purchaseUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get purchaseUnavailable;

  /// No description provided for @purchaseLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get purchaseLoading;

  /// No description provided for @purchaseError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during purchase. Please try again later.'**
  String get purchaseError;

  /// No description provided for @rankingScoreSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Score {score} submitted successfully!'**
  String rankingScoreSubmitted(Object score);

  /// No description provided for @rankingScoreSubmissionFailed.
  ///
  /// In en, this message translates to:
  /// **'Score submission failed'**
  String get rankingScoreSubmissionFailed;

  /// No description provided for @rankingRank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rankingRank;

  /// No description provided for @rankingPlayer.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get rankingPlayer;

  /// No description provided for @rankingScore.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get rankingScore;

  /// No description provided for @rankingSubmitScore.
  ///
  /// In en, this message translates to:
  /// **'Submit Score'**
  String get rankingSubmitScore;

  /// No description provided for @rankingGameCenter.
  ///
  /// In en, this message translates to:
  /// **'Game Center'**
  String get rankingGameCenter;

  /// No description provided for @rankingInApp.
  ///
  /// In en, this message translates to:
  /// **'In-App'**
  String get rankingInApp;

  /// No description provided for @languageLanguageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageLanguageSettings;

  /// No description provided for @languageJapanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get languageJapanese;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageRestartRequired.
  ///
  /// In en, this message translates to:
  /// **'Please restart the app'**
  String get languageRestartRequired;

  /// No description provided for @dailyChallengeDailyChallenge.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge'**
  String get dailyChallengeDailyChallenge;

  /// No description provided for @dailyChallengeCompleted.
  ///
  /// In en, this message translates to:
  /// **'Daily challenge completed! Earned {reward} taps'**
  String dailyChallengeCompleted(Object reward);

  /// No description provided for @dailyChallengeWatchAdForReward.
  ///
  /// In en, this message translates to:
  /// **'Watch video to earn rewards'**
  String get dailyChallengeWatchAdForReward;

  /// No description provided for @dailyChallengeShareScreenshot.
  ///
  /// In en, this message translates to:
  /// **'Share screenshot'**
  String get dailyChallengeShareScreenshot;

  /// No description provided for @dailyChallengeLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get dailyChallengeLevel;

  /// No description provided for @dailyChallengeTotalTaps.
  ///
  /// In en, this message translates to:
  /// **'Total Taps'**
  String get dailyChallengeTotalTaps;

  /// No description provided for @dailyChallengeTodayTaps.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Taps'**
  String get dailyChallengeTodayTaps;

  /// No description provided for @dailyChallengeTapButton.
  ///
  /// In en, this message translates to:
  /// **'TAP!'**
  String get dailyChallengeTapButton;

  /// No description provided for @purchaseRestoreStarted.
  ///
  /// In en, this message translates to:
  /// **'Purchase restoration started'**
  String get purchaseRestoreStarted;

  /// No description provided for @purchaseRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase restoration failed. Please try again later.'**
  String get purchaseRestoreFailed;

  /// No description provided for @purchaseRestoreFailedRetry.
  ///
  /// In en, this message translates to:
  /// **'Purchase restoration failed. Please try again later.'**
  String get purchaseRestoreFailedRetry;

  /// No description provided for @tutorialDailyChallengeDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete daily challenges to earn special rewards.'**
  String get tutorialDailyChallengeDescription;

  /// No description provided for @levelSkipCurrentTapsMaxLevel.
  ///
  /// In en, this message translates to:
  /// **'Skip to the highest level (Lv.{level}) achievable with your current tap count?\n\nCurrent tap count: {currentTaps}\nHighest achievable level: Lv.{level}\n\nAfter skipping, your current tap count will remain the same, but your level will be set to the highest level.'**
  String levelSkipCurrentTapsMaxLevel(Object currentTaps, Object level);

  /// No description provided for @logsSkipApproved.
  ///
  /// In en, this message translates to:
  /// **'Skip approved'**
  String get logsSkipApproved;

  /// No description provided for @logsAlreadyMaxLevel.
  ///
  /// In en, this message translates to:
  /// **'Already at maximum level'**
  String get logsAlreadyMaxLevel;

  /// No description provided for @logsSkipError.
  ///
  /// In en, this message translates to:
  /// **'Error occurred during skip process: {error}'**
  String logsSkipError(Object error);

  /// No description provided for @logsSkipErrorSnackbar.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during the skip process: {error}'**
  String logsSkipErrorSnackbar(Object error);

  /// No description provided for @weekdayMonday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdaySaturday;

  /// No description provided for @weekdaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdaySunday;

  /// No description provided for @notificationAppName.
  ///
  /// In en, this message translates to:
  /// **'Impossible Tap'**
  String get notificationAppName;

  /// No description provided for @notificationChannelName.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminder'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Daily tap reminder at 8 PM'**
  String get notificationChannelDescription;

  /// No description provided for @notificationChannelNameMain.
  ///
  /// In en, this message translates to:
  /// **'Impossible Tap'**
  String get notificationChannelNameMain;

  /// No description provided for @notificationChannelDescriptionMain.
  ///
  /// In en, this message translates to:
  /// **'Impossible Tap notifications'**
  String get notificationChannelDescriptionMain;

  /// No description provided for @notificationMessage1.
  ///
  /// In en, this message translates to:
  /// **'Haven\'t tapped today?'**
  String get notificationMessage1;

  /// No description provided for @notificationMessage2.
  ///
  /// In en, this message translates to:
  /// **'It\'s time to tap!'**
  String get notificationMessage2;

  /// No description provided for @notificationMessage3.
  ///
  /// In en, this message translates to:
  /// **'Still haven\'t tapped?'**
  String get notificationMessage3;

  /// No description provided for @notificationMessage4.
  ///
  /// In en, this message translates to:
  /// **'Let\'s tap hard today too!'**
  String get notificationMessage4;

  /// No description provided for @notificationMessage5.
  ///
  /// In en, this message translates to:
  /// **'Level up with taps!'**
  String get notificationMessage5;

  /// No description provided for @notificationMessage6.
  ///
  /// In en, this message translates to:
  /// **'Have you tapped today?'**
  String get notificationMessage6;

  /// No description provided for @notificationMessage7.
  ///
  /// In en, this message translates to:
  /// **'It\'s tap time!'**
  String get notificationMessage7;

  /// No description provided for @notificationMessage8.
  ///
  /// In en, this message translates to:
  /// **'You can still tap more!'**
  String get notificationMessage8;

  /// No description provided for @notificationMessage9.
  ///
  /// In en, this message translates to:
  /// **'Set a new record with today\'s taps!'**
  String get notificationMessage9;

  /// No description provided for @notificationMessage10.
  ///
  /// In en, this message translates to:
  /// **'Create a new record with taps!'**
  String get notificationMessage10;

  /// No description provided for @notificationMessage11.
  ///
  /// In en, this message translates to:
  /// **'Have you achieved today\'s tap goal?'**
  String get notificationMessage11;

  /// No description provided for @notificationMessage12.
  ///
  /// In en, this message translates to:
  /// **'Relieve stress with taps!'**
  String get notificationMessage12;

  /// No description provided for @notificationMessage13.
  ///
  /// In en, this message translates to:
  /// **'Have fun tapping today too!'**
  String get notificationMessage13;

  /// No description provided for @notificationMessage14.
  ///
  /// In en, this message translates to:
  /// **'Brain training with taps!'**
  String get notificationMessage14;

  /// No description provided for @notificationMessage15.
  ///
  /// In en, this message translates to:
  /// **'How many taps today?'**
  String get notificationMessage15;

  /// No description provided for @notificationMessage16.
  ///
  /// In en, this message translates to:
  /// **'Improve concentration with taps!'**
  String get notificationMessage16;

  /// No description provided for @notificationMessage17.
  ///
  /// In en, this message translates to:
  /// **'Let\'s work hard with taps today too!'**
  String get notificationMessage17;

  /// No description provided for @notificationMessage18.
  ///
  /// In en, this message translates to:
  /// **'Refresh with taps!'**
  String get notificationMessage18;

  /// No description provided for @notificationMessage19.
  ///
  /// In en, this message translates to:
  /// **'Have you tapped today?'**
  String get notificationMessage19;

  /// No description provided for @notificationMessage20.
  ///
  /// In en, this message translates to:
  /// **'Make new discoveries with taps!'**
  String get notificationMessage20;

  /// No description provided for @titleGod.
  ///
  /// In en, this message translates to:
  /// **'Tap God'**
  String get titleGod;

  /// No description provided for @titleSage.
  ///
  /// In en, this message translates to:
  /// **'Tap Sage'**
  String get titleSage;

  /// No description provided for @titleMaster.
  ///
  /// In en, this message translates to:
  /// **'Tap Master'**
  String get titleMaster;

  /// No description provided for @titleExpert.
  ///
  /// In en, this message translates to:
  /// **'Tap Expert'**
  String get titleExpert;

  /// No description provided for @titleIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get titleIntermediate;

  /// No description provided for @titleBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get titleBeginner;

  /// No description provided for @titleNovice.
  ///
  /// In en, this message translates to:
  /// **'Novice'**
  String get titleNovice;

  /// No description provided for @titleApprentice.
  ///
  /// In en, this message translates to:
  /// **'Apprentice'**
  String get titleApprentice;

  /// No description provided for @titleNewbie.
  ///
  /// In en, this message translates to:
  /// **'Newbie'**
  String get titleNewbie;

  /// No description provided for @productRemoveAds.
  ///
  /// In en, this message translates to:
  /// **'Remove Banner Ads'**
  String get productRemoveAds;

  /// No description provided for @productTap10.
  ///
  /// In en, this message translates to:
  /// **'1 Tap = 10 Taps'**
  String get productTap10;

  /// No description provided for @productTap100.
  ///
  /// In en, this message translates to:
  /// **'1 Tap = 100 Taps'**
  String get productTap100;

  /// No description provided for @productTap1000.
  ///
  /// In en, this message translates to:
  /// **'1 Tap = 1,000 Taps'**
  String get productTap1000;

  /// No description provided for @productTap1M.
  ///
  /// In en, this message translates to:
  /// **'1 Tap = 1 Million Taps'**
  String get productTap1M;

  /// No description provided for @productTap100M.
  ///
  /// In en, this message translates to:
  /// **'1 Tap = 100 Million Taps'**
  String get productTap100M;

  /// No description provided for @productUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown Product'**
  String get productUnknown;

  /// No description provided for @productDescriptionRemoveAds.
  ///
  /// In en, this message translates to:
  /// **'Hide only banner ads.\n(Video ads remain available)'**
  String get productDescriptionRemoveAds;

  /// No description provided for @productDescriptionTap10.
  ///
  /// In en, this message translates to:
  /// **'Get 10x effect per tap\n※Added permanently'**
  String get productDescriptionTap10;

  /// No description provided for @productDescriptionTap100.
  ///
  /// In en, this message translates to:
  /// **'Get 100x effect per tap\n※Added permanently'**
  String get productDescriptionTap100;

  /// No description provided for @productDescriptionTap1000.
  ///
  /// In en, this message translates to:
  /// **'Get 1,000x effect per tap\n※Added permanently'**
  String get productDescriptionTap1000;

  /// No description provided for @productDescriptionTap1M.
  ///
  /// In en, this message translates to:
  /// **'Get 1,000,000x effect per tap\n※Added permanently'**
  String get productDescriptionTap1M;

  /// No description provided for @productDescriptionTap100M.
  ///
  /// In en, this message translates to:
  /// **'Get 100,000,000x effect per tap\n※Added permanently'**
  String get productDescriptionTap100M;

  /// No description provided for @productDescriptionUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown effect'**
  String get productDescriptionUnknown;

  /// No description provided for @productPriceUnknown.
  ///
  /// In en, this message translates to:
  /// **'Price unknown'**
  String get productPriceUnknown;

  /// No description provided for @ageVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Age Verification'**
  String get ageVerificationTitle;

  /// No description provided for @ageVerificationContent.
  ///
  /// In en, this message translates to:
  /// **'Purchase amounts are limited based on your age.\n\nAre you 20 years old or older?'**
  String get ageVerificationContent;

  /// No description provided for @ageVerificationYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get ageVerificationYes;

  /// No description provided for @ageVerificationNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get ageVerificationNo;

  /// No description provided for @shareDefaultText.
  ///
  /// In en, this message translates to:
  /// **'Playing Impossible Tap!'**
  String get shareDefaultText;

  /// No description provided for @shareAppSubject.
  ///
  /// In en, this message translates to:
  /// **'Impossible Tap'**
  String get shareAppSubject;

  /// No description provided for @shareAppInfo.
  ///
  /// In en, this message translates to:
  /// **'Impossible Tap\n\n🎮 Addictive tap game\n📈 Level up to earn titles\n🏆 Compete in rankings\n🎁 Earn rewards by watching videos\n💰 Increase tap multiplier with purchases\n\n#ImpossibleTap #TapGame #Game'**
  String get shareAppInfo;

  /// No description provided for @levelDisplayNextLevel.
  ///
  /// In en, this message translates to:
  /// **'To Next Level'**
  String get levelDisplayNextLevel;

  /// No description provided for @levelDisplayLevel.
  ///
  /// In en, this message translates to:
  /// **'Lv.'**
  String get levelDisplayLevel;

  /// No description provided for @statsDisplayTotalTaps.
  ///
  /// In en, this message translates to:
  /// **'Total Taps'**
  String get statsDisplayTotalTaps;

  /// No description provided for @statsDisplayThousand.
  ///
  /// In en, this message translates to:
  /// **'K'**
  String get statsDisplayThousand;

  /// No description provided for @statsDisplayTenThousand.
  ///
  /// In en, this message translates to:
  /// **'10K'**
  String get statsDisplayTenThousand;

  /// No description provided for @statsChartNoData.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get statsChartNoData;

  /// No description provided for @statsChartTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get statsChartTotal;

  /// No description provided for @statsChartTaps.
  ///
  /// In en, this message translates to:
  /// **'taps'**
  String get statsChartTaps;

  /// No description provided for @rankingYourRecord.
  ///
  /// In en, this message translates to:
  /// **'Your Record'**
  String get rankingYourRecord;

  /// No description provided for @rankingTotalTaps.
  ///
  /// In en, this message translates to:
  /// **'Total Taps'**
  String get rankingTotalTaps;

  /// No description provided for @rankingCurrentLevel.
  ///
  /// In en, this message translates to:
  /// **'Current Level'**
  String get rankingCurrentLevel;

  /// No description provided for @rankingGameCenterRecord.
  ///
  /// In en, this message translates to:
  /// **'GameCenter Record'**
  String get rankingGameCenterRecord;

  /// No description provided for @rankingLastSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Last Submitted'**
  String get rankingLastSubmitted;

  /// No description provided for @rankingUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get rankingUploading;

  /// No description provided for @rankingViewInGameCenter.
  ///
  /// In en, this message translates to:
  /// **'View in GameCenter'**
  String get rankingViewInGameCenter;

  /// No description provided for @rankingSignInToGameCenter.
  ///
  /// In en, this message translates to:
  /// **'Sign In to GameCenter'**
  String get rankingSignInToGameCenter;

  /// No description provided for @rankingSubmitTaps.
  ///
  /// In en, this message translates to:
  /// **'Submit Tap Count'**
  String get rankingSubmitTaps;

  /// No description provided for @rankingGameCenterIosOnly.
  ///
  /// In en, this message translates to:
  /// **'GameCenter is iOS only'**
  String get rankingGameCenterIosOnly;

  /// No description provided for @rankingGameCenterDescription.
  ///
  /// In en, this message translates to:
  /// **'Ranking features are only available on iOS devices.'**
  String get rankingGameCenterDescription;

  /// No description provided for @rankingLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Ranking'**
  String get rankingLeaderboard;

  /// No description provided for @rankingAbout.
  ///
  /// In en, this message translates to:
  /// **'About Ranking'**
  String get rankingAbout;

  /// No description provided for @rankingAboutDescription.
  ///
  /// In en, this message translates to:
  /// **'• Total tap count is reflected in ranking\n• Score is automatically submitted when leveling up\n• You can also manually submit via \"Submit Tap Count\"\n• Ranking is automatically displayed in-app\n• \"View in GameCenter\" provides access to standard GameCenter screen'**
  String get rankingAboutDescription;

  /// No description provided for @rankingShareTooltip.
  ///
  /// In en, this message translates to:
  /// **'Share screenshot'**
  String get rankingShareTooltip;

  /// No description provided for @titleDisplayRemainingTaps.
  ///
  /// In en, this message translates to:
  /// **'{remaining} more taps to {title}'**
  String titleDisplayRemainingTaps(Object remaining, Object title);

  /// No description provided for @titleDisplayNextTitle.
  ///
  /// In en, this message translates to:
  /// **'Next Title'**
  String get titleDisplayNextTitle;

  /// No description provided for @homeWatchVideoEarn.
  ///
  /// In en, this message translates to:
  /// **'Watch video to earn'**
  String get homeWatchVideoEarn;

  /// No description provided for @homeSkipToLevel.
  ///
  /// In en, this message translates to:
  /// **'Skip to Lv.{level}'**
  String homeSkipToLevel(Object level);

  /// No description provided for @homeLevelSkip.
  ///
  /// In en, this message translates to:
  /// **'Level Skip'**
  String get homeLevelSkip;

  /// No description provided for @homeNextLevelReached.
  ///
  /// In en, this message translates to:
  /// **'Next level reached!'**
  String get homeNextLevelReached;

  /// No description provided for @homeRemainingTapsToLevel.
  ///
  /// In en, this message translates to:
  /// **'{remaining} more taps to level up!'**
  String homeRemainingTapsToLevel(Object remaining);

  /// No description provided for @homeSkipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get homeSkipButton;

  /// No description provided for @homeTotalTapsLabel.
  ///
  /// In en, this message translates to:
  /// **'TOTAL TAPS'**
  String get homeTotalTapsLabel;

  /// No description provided for @homeNextLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'NEXT LEVEL'**
  String get homeNextLevelLabel;

  /// No description provided for @tutorialTitle.
  ///
  /// In en, this message translates to:
  /// **'Tutorial'**
  String get tutorialTitle;

  /// No description provided for @tutorialTapToLevelUp.
  ///
  /// In en, this message translates to:
  /// **'Tap to Level Up'**
  String get tutorialTapToLevelUp;

  /// No description provided for @tutorialTapToLevelUpDescription.
  ///
  /// In en, this message translates to:
  /// **'Tap the center button to level up. Your title changes as you level up.'**
  String get tutorialTapToLevelUpDescription;

  /// No description provided for @tutorialWatchVideoForReward.
  ///
  /// In en, this message translates to:
  /// **'Watch Video for Reward'**
  String get tutorialWatchVideoForReward;

  /// No description provided for @tutorialWatchVideoForRewardDescription.
  ///
  /// In en, this message translates to:
  /// **'Watch video ads to earn 100 taps as reward.'**
  String get tutorialWatchVideoForRewardDescription;

  /// No description provided for @tutorialAchievementTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievement'**
  String get tutorialAchievementTitle;

  /// No description provided for @tutorialAchievementDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete various goals to unlock achievements.'**
  String get tutorialAchievementDescription;

  /// No description provided for @achievementTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievement'**
  String get achievementTitle;

  /// No description provided for @achievementLevel10Title.
  ///
  /// In en, this message translates to:
  /// **'Level 10 Achieved'**
  String get achievementLevel10Title;

  /// No description provided for @achievementLevel10Description.
  ///
  /// In en, this message translates to:
  /// **'Reached level 10'**
  String get achievementLevel10Description;

  /// No description provided for @achievementLevel50Title.
  ///
  /// In en, this message translates to:
  /// **'Level 50 Achieved'**
  String get achievementLevel50Title;

  /// No description provided for @achievementLevel50Description.
  ///
  /// In en, this message translates to:
  /// **'Reached level 50'**
  String get achievementLevel50Description;

  /// No description provided for @achievementLevel100Title.
  ///
  /// In en, this message translates to:
  /// **'Level 100 Achieved'**
  String get achievementLevel100Title;

  /// No description provided for @achievementLevel100Description.
  ///
  /// In en, this message translates to:
  /// **'Reached level 100'**
  String get achievementLevel100Description;

  /// No description provided for @achievement1000TapsTitle.
  ///
  /// In en, this message translates to:
  /// **'1000 Taps Achieved'**
  String get achievement1000TapsTitle;

  /// No description provided for @achievement1000TapsDescription.
  ///
  /// In en, this message translates to:
  /// **'Tapped 1000 times'**
  String get achievement1000TapsDescription;

  /// No description provided for @achievement10000TapsTitle.
  ///
  /// In en, this message translates to:
  /// **'10000 Taps Achieved'**
  String get achievement10000TapsTitle;

  /// No description provided for @achievement10000TapsDescription.
  ///
  /// In en, this message translates to:
  /// **'Tapped 10000 times'**
  String get achievement10000TapsDescription;

  /// No description provided for @dailyChallengeReward.
  ///
  /// In en, this message translates to:
  /// **'Reward: {taps} taps'**
  String dailyChallengeReward(Object taps);

  /// No description provided for @dailyChallengeAlreadyCompleted.
  ///
  /// In en, this message translates to:
  /// **'Today\'s daily challenge is already completed. Try again tomorrow!'**
  String get dailyChallengeAlreadyCompleted;

  /// No description provided for @dailyChallengeTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge'**
  String get dailyChallengeTitle;

  /// No description provided for @videoAdTitle.
  ///
  /// In en, this message translates to:
  /// **'Video Ad'**
  String get videoAdTitle;

  /// No description provided for @videoAdDescription.
  ///
  /// In en, this message translates to:
  /// **'Watch video ad to earn rewards?\n\nAfter completion, you will earn 250 taps.'**
  String get videoAdDescription;

  /// No description provided for @videoAdFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to watch video. No reward earned.'**
  String get videoAdFailed;

  /// No description provided for @videoAdCompletedWithError.
  ///
  /// In en, this message translates to:
  /// **'Video completed! Earned 250 taps (error occurred but reward given)'**
  String get videoAdCompletedWithError;

  /// No description provided for @watchVideoTooltip.
  ///
  /// In en, this message translates to:
  /// **'Watch video to earn reward'**
  String get watchVideoTooltip;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @watchVideo.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get watchVideo;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get understood;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @purchaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchase Items'**
  String get purchaseTitle;

  /// No description provided for @purchaseButton.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get purchaseButton;

  /// No description provided for @settingsContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get settingsContact;

  /// No description provided for @settingsContactDescription.
  ///
  /// In en, this message translates to:
  /// **'Bug reports and feature requests'**
  String get settingsContactDescription;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsPrivacyDescription.
  ///
  /// In en, this message translates to:
  /// **'Personal information handling'**
  String get settingsPrivacyDescription;

  /// No description provided for @settingsTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsTermsOfService;

  /// No description provided for @settingsTermsDescription.
  ///
  /// In en, this message translates to:
  /// **'App usage conditions'**
  String get settingsTermsDescription;

  /// No description provided for @settingsDeleteData.
  ///
  /// In en, this message translates to:
  /// **'Delete Data'**
  String get settingsDeleteData;

  /// No description provided for @settingsDeleteDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Reset all data'**
  String get settingsDeleteDataDescription;

  /// No description provided for @settingsDailyNotification.
  ///
  /// In en, this message translates to:
  /// **'Daily 8 PM Notification'**
  String get settingsDailyNotification;

  /// No description provided for @settingsDailyNotificationDescription.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder to tap at 8 PM'**
  String get settingsDailyNotificationDescription;

  /// No description provided for @settingsDataDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Data Deletion'**
  String get settingsDataDeleteConfirmTitle;

  /// No description provided for @settingsDataDeleteConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'All data (tap count, level, statistics, etc.) will be deleted.\nThis action cannot be undone.\n\nAre you sure you want to delete?'**
  String get settingsDataDeleteConfirmContent;

  /// No description provided for @settingsDataDeleteConfirmCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsDataDeleteConfirmCancel;

  /// No description provided for @settingsDataDeleteConfirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get settingsDataDeleteConfirmDelete;

  /// No description provided for @settingsNotificationEnabled.
  ///
  /// In en, this message translates to:
  /// **'Daily 8 PM notification enabled'**
  String get settingsNotificationEnabled;

  /// No description provided for @settingsNotificationDisabled.
  ///
  /// In en, this message translates to:
  /// **'Daily 8 PM notification disabled'**
  String get settingsNotificationDisabled;

  /// No description provided for @dailyChallengeCompletedShort.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get dailyChallengeCompletedShort;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MURITAP'**
  String get appTitle;

  /// No description provided for @tutorialDailyChallengeTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge'**
  String get tutorialDailyChallengeTitle;

  /// No description provided for @settingsAppInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'App Information'**
  String get settingsAppInfoTitle;

  /// No description provided for @settingsCurrentLevel.
  ///
  /// In en, this message translates to:
  /// **'Current Level'**
  String get settingsCurrentLevel;

  /// No description provided for @settingsCurrentTapMultiplier.
  ///
  /// In en, this message translates to:
  /// **'Current Tap Multiplier'**
  String get settingsCurrentTapMultiplier;

  /// No description provided for @settingsTodayStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Statistics'**
  String get settingsTodayStatsTitle;

  /// No description provided for @settingsTodayTaps.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Taps'**
  String get settingsTodayTaps;

  /// No description provided for @settingsTodayActualTaps.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Actual Taps'**
  String get settingsTodayActualTaps;

  /// No description provided for @settingsTotalTaps.
  ///
  /// In en, this message translates to:
  /// **'Total Taps'**
  String get settingsTotalTaps;

  /// No description provided for @settingsCurrentLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Level'**
  String get settingsCurrentLevelLabel;

  /// No description provided for @settingsWeeklyRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'This Week\'s Record'**
  String get settingsWeeklyRecordTitle;

  /// No description provided for @settingsMonthlyRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Past 30 Days Record'**
  String get settingsMonthlyRecordTitle;

  /// No description provided for @settingsPurchaseDescription.
  ///
  /// In en, this message translates to:
  /// **'You can purchase features such as ad removal and tap multiplier increase.'**
  String get settingsPurchaseDescription;

  /// No description provided for @settingsPurchased.
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get settingsPurchased;

  /// No description provided for @homeSkipSuccess.
  ///
  /// In en, this message translates to:
  /// **'Skipped to Lv.{level}!'**
  String homeSkipSuccess(Object level);

  /// No description provided for @homeAlreadyMaxLevel.
  ///
  /// In en, this message translates to:
  /// **'You have already reached the maximum level.'**
  String get homeAlreadyMaxLevel;

  /// No description provided for @homeSkipError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during skip process: {error}'**
  String homeSkipError(Object error);

  /// No description provided for @homeVideoAdSuccess.
  ///
  /// In en, this message translates to:
  /// **'Video watching completed! You earned 250 taps'**
  String get homeVideoAdSuccess;

  /// No description provided for @homeVideoAdLoading.
  ///
  /// In en, this message translates to:
  /// **'Video advertisement is loading. Please wait and try again.'**
  String get homeVideoAdLoading;

  /// No description provided for @homeLevelUpNotification.
  ///
  /// In en, this message translates to:
  /// **'LEVEL UP! Lv.{level}'**
  String homeLevelUpNotification(Object level);

  /// No description provided for @homeAchievementLevel10Title.
  ///
  /// In en, this message translates to:
  /// **'Level 10 Achieved'**
  String get homeAchievementLevel10Title;

  /// No description provided for @homeAchievementLevel10Description.
  ///
  /// In en, this message translates to:
  /// **'Reached level 10'**
  String get homeAchievementLevel10Description;

  /// No description provided for @homeAchievementLevel50Title.
  ///
  /// In en, this message translates to:
  /// **'Level 50 Achieved'**
  String get homeAchievementLevel50Title;

  /// No description provided for @homeAchievementLevel50Description.
  ///
  /// In en, this message translates to:
  /// **'Reached level 50'**
  String get homeAchievementLevel50Description;

  /// No description provided for @homeAchievementLevel100Title.
  ///
  /// In en, this message translates to:
  /// **'Level 100 Achieved'**
  String get homeAchievementLevel100Title;

  /// No description provided for @homeAchievementLevel100Description.
  ///
  /// In en, this message translates to:
  /// **'Reached level 100'**
  String get homeAchievementLevel100Description;

  /// No description provided for @homeAchievement1000TapsTitle.
  ///
  /// In en, this message translates to:
  /// **'1000 Taps Achieved'**
  String get homeAchievement1000TapsTitle;

  /// No description provided for @homeAchievement1000TapsDescription.
  ///
  /// In en, this message translates to:
  /// **'Tapped 1000 times'**
  String get homeAchievement1000TapsDescription;

  /// No description provided for @homeAchievement10000TapsTitle.
  ///
  /// In en, this message translates to:
  /// **'10000 Taps Achieved'**
  String get homeAchievement10000TapsTitle;

  /// No description provided for @homeAchievement10000TapsDescription.
  ///
  /// In en, this message translates to:
  /// **'Tapped 10000 times'**
  String get homeAchievement10000TapsDescription;

  /// No description provided for @settingsEmailAppError.
  ///
  /// In en, this message translates to:
  /// **'Could not open email app'**
  String get settingsEmailAppError;

  /// No description provided for @settingsEmailSendError.
  ///
  /// In en, this message translates to:
  /// **'Email sending error: {error}'**
  String settingsEmailSendError(Object error);

  /// No description provided for @settingsDataDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'All data has been deleted'**
  String get settingsDataDeleteSuccess;

  /// No description provided for @settingsDataDeleteError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while deleting data: {error}'**
  String settingsDataDeleteError(Object error);

  /// No description provided for @settingsNotificationSettingError.
  ///
  /// In en, this message translates to:
  /// **'Notification setting error: {error}'**
  String settingsNotificationSettingError(Object error);

  /// No description provided for @settingsPurchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed. Please try again later.'**
  String get settingsPurchaseFailed;

  /// No description provided for @settingsPurchaseSuccess.
  ///
  /// In en, this message translates to:
  /// **'{productName} purchased successfully!'**
  String settingsPurchaseSuccess(Object productName);

  /// No description provided for @purchaseSuccess.
  ///
  /// In en, this message translates to:
  /// **'{productName} purchased successfully!'**
  String purchaseSuccess(Object productName);

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed. Please try again later.'**
  String get purchaseFailed;

  /// No description provided for @purchaseTap10.
  ///
  /// In en, this message translates to:
  /// **'1 Tap = 10 Taps'**
  String get purchaseTap10;

  /// No description provided for @purchaseTap100.
  ///
  /// In en, this message translates to:
  /// **'1 Tap = 100 Taps'**
  String get purchaseTap100;

  /// No description provided for @purchaseTap1000.
  ///
  /// In en, this message translates to:
  /// **'1 Tap = 1000 Taps'**
  String get purchaseTap1000;

  /// No description provided for @purchaseTap10Description.
  ///
  /// In en, this message translates to:
  /// **'Get 10 taps effect with 1 tap\n※Permanently added'**
  String get purchaseTap10Description;

  /// No description provided for @purchaseTap100Description.
  ///
  /// In en, this message translates to:
  /// **'Get 100 taps effect with 1 tap\n※Permanently added'**
  String get purchaseTap100Description;

  /// No description provided for @purchaseTap1000Description.
  ///
  /// In en, this message translates to:
  /// **'Get 1000 taps effect with 1 tap\n※Permanently added'**
  String get purchaseTap1000Description;

  /// No description provided for @notificationGeneralChannelName.
  ///
  /// In en, this message translates to:
  /// **'Impossible Tap'**
  String get notificationGeneralChannelName;

  /// No description provided for @notificationGeneralChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Impossible Tap notifications'**
  String get notificationGeneralChannelDescription;

  /// No description provided for @homeShareText.
  ///
  /// In en, this message translates to:
  /// **'Achieved level {level} with {totalTaps} total taps in Impossible Tap!\nJoin the ranking too!\nApp download (iOS):\nhttps://apps.apple.com/jp/developer/jin-mizoi/id1548623319'**
  String homeShareText(Object level, Object totalTaps);
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
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
