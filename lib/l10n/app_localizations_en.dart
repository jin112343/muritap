// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'MURITAP';

  @override
  String get navigationRanking => 'Ranking';

  @override
  String get navigationHome => 'Home';

  @override
  String get navigationSettings => 'Settings';

  @override
  String get homeLevel => 'Level';

  @override
  String get homeTotalTaps => 'Total Taps';

  @override
  String get homeTodayTaps => 'Today\'s Taps';

  @override
  String get homeTapButton => 'TAP!';

  @override
  String get homeLevelUp => 'Level Up!';

  @override
  String get homeNewRecord => 'New Record!';

  @override
  String get homeAchievement => 'Achievement Unlocked!';

  @override
  String get homeRatingDialogTitle => '100 Taps Achieved!';

  @override
  String get homeRatingDialogContent =>
      '🎉 Congratulations! You\'ve achieved 100 taps!\n\nDid you enjoy this app?\nIf you liked it, could you give us a 5-star rating on the App Store?\n\nYour rating helps us improve the app.';

  @override
  String get homeRatingDialogLater => 'Later';

  @override
  String get homeRatingDialogRateOnAppStore => 'Rate on App Store';

  @override
  String get rankingTitle => 'Ranking';

  @override
  String get rankingSignIn => 'Sign In to Game Center';

  @override
  String get rankingShowLeaderboard => 'Show Leaderboard';

  @override
  String get rankingInAppRanking => 'In-App Ranking';

  @override
  String get rankingShare => 'Share';

  @override
  String rankingShareText(Object level, Object taps) {
    return 'Achieved Level $level with $taps total taps in MURITAP!\nJoin the ranking too!\nDownload the app here (iOS):\nhttps://apps.apple.com/jp/developer/jin-mizoi/id1548623319';
  }

  @override
  String get rankingNoData => 'No ranking data available';

  @override
  String get rankingLoading => 'Loading...';

  @override
  String get rankingError => 'Error occurred';

  @override
  String get settingsTabsSettings => 'Settings';

  @override
  String get settingsTabsStats => 'Statistics';

  @override
  String get settingsTabsPurchase => 'Purchase';

  @override
  String get settingsGeneralTitle => 'General Settings';

  @override
  String get settingsGeneralDailyNotification => 'Daily Notification (8 PM)';

  @override
  String get settingsGeneralNotificationDescription =>
      'Receive a daily reminder to play';

  @override
  String get settingsGeneralAppInfo => 'App Information';

  @override
  String get settingsGeneralVersion => 'Version';

  @override
  String get settingsGeneralBuildNumber => 'Build Number';

  @override
  String get settingsGeneralDeveloper => 'Developer';

  @override
  String get settingsGeneralPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsGeneralTermsOfService => 'Terms of Service';

  @override
  String get settingsStatsTitle => 'Statistics';

  @override
  String get settingsStatsToday => 'Today';

  @override
  String get settingsStatsThisWeek => 'This Week';

  @override
  String get settingsStatsThisMonth => 'This Month';

  @override
  String get settingsStatsTotalTaps => 'Total Taps';

  @override
  String get settingsStatsCurrentLevel => 'Current Level';

  @override
  String get settingsStatsAverageTapsPerDay => 'Average Taps/Day';

  @override
  String get settingsStatsBestDay => 'Best Day';

  @override
  String get settingsStatsStreak => 'Streak';

  @override
  String get settingsPurchaseTitle => 'Purchase Items';

  @override
  String get settingsPurchaseRemoveAds => 'Remove Ads';

  @override
  String get settingsPurchaseRemoveAdsDescription =>
      'Enjoy the game without advertisements';

  @override
  String get settingsPurchaseRestore => 'Restore Purchases';

  @override
  String get settingsPurchasePurchase => 'Purchase';

  @override
  String get settingsPurchasePurchased => 'Purchased';

  @override
  String get settingsPurchaseUnavailable => 'Unavailable';

  @override
  String get settingsPurchaseLoading => 'Loading...';

  @override
  String get settingsPurchaseError =>
      'An error occurred during purchase. Please try again later.';

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonError => 'Error';

  @override
  String get commonSuccess => 'Success';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonRestore => 'Restore';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonWatch => 'Watch';

  @override
  String get commonUnderstand => 'I understand';

  @override
  String get commonRestart => 'Restart';

  @override
  String get dialogsLevelSkipTitle => 'Level Skip';

  @override
  String get dialogsLevelSkipContent =>
      'Skip to the next level? This will consume your skip tickets.';

  @override
  String get dialogsLevelSkipSkip => 'Skip';

  @override
  String get dialogsLevelSkipCancel => 'Cancel';

  @override
  String dialogsLevelSkipSuccess(Object level) {
    return 'Skipped to Level $level!';
  }

  @override
  String get dialogsLevelSkipMaxLevel =>
      'You have already reached the maximum level.';

  @override
  String dialogsLevelSkipError(Object error) {
    return 'An error occurred during skip process: $error';
  }

  @override
  String get dialogsDailyChallengeAlreadyCompleted =>
      'Today\'s daily challenge is already completed. Please try again tomorrow!';

  @override
  String dialogsDailyChallengeCompleted(Object reward) {
    return 'Daily challenge completed! You earned $reward taps';
  }

  @override
  String get dialogsDailyChallengeNotAvailable =>
      'Daily challenge is not available yet';

  @override
  String get dialogsVideoAdTitle => 'Video Advertisement';

  @override
  String get dialogsVideoAdContent =>
      'Watch a video advertisement to earn rewards?\n\nAfter watching, you will earn 250 taps.';

  @override
  String get dialogsVideoAdWatch => 'Watch';

  @override
  String get dialogsVideoAdCancel => 'Cancel';

  @override
  String get dialogsVideoAdSuccess =>
      'Video watching completed! You earned 250 taps';

  @override
  String get dialogsVideoAdFailed =>
      'Video watching failed. You could not earn rewards.';

  @override
  String get dialogsVideoAdSuccessWithError =>
      'Video watching completed! You earned 250 taps (an error occurred but rewards were given)';

  @override
  String get dialogsVideoAdLoading =>
      'Video advertisement is loading. Please wait and try again.';

  @override
  String get dialogsDataDeleteTitle => 'Confirm Data Deletion';

  @override
  String get dialogsDataDeleteContent =>
      'Are you sure you want to delete all data? This action cannot be undone.';

  @override
  String get dialogsDataDeleteDelete => 'Delete';

  @override
  String get dialogsDataDeleteCancel => 'Cancel';

  @override
  String get dialogsDataDeleteSuccess => 'All data has been deleted';

  @override
  String dialogsDataDeleteError(Object error) {
    return 'An error occurred while deleting data: $error';
  }

  @override
  String get dialogsLanguageChangeTitle => 'Change language?';

  @override
  String get dialogsLanguageChangeContent =>
      'You need to restart the app to change the language.';

  @override
  String get dialogsLanguageChangeRestart => 'Restart';

  @override
  String get dialogsLanguageChangeCancel => 'Cancel';

  @override
  String dialogsPurchaseSuccess(Object productName) {
    return '$productName purchased successfully!';
  }

  @override
  String get dialogsPurchaseFailed =>
      'Purchase failed. Please try again later.';

  @override
  String get dialogsPurchaseError =>
      'An error occurred during purchase. Please try again later.';

  @override
  String get dialogsPurchaseRestoreStarted => 'Purchase restoration started';

  @override
  String get dialogsPurchaseRestoreFailed =>
      'Purchase restoration failed. Please try again later.';

  @override
  String get dialogsNotificationEnabled => 'Daily 8 PM notification enabled';

  @override
  String get dialogsNotificationDisabled => 'Daily 8 PM notification disabled';

  @override
  String dialogsNotificationError(Object error) {
    return 'Notification setting error: $error';
  }

  @override
  String get dialogsEmailError => 'Could not open email app';

  @override
  String dialogsEmailSendError(Object error) {
    return 'Email sending error: $error';
  }

  @override
  String dialogsScoreSubmitSuccess(Object score) {
    return 'Score $score submitted successfully!';
  }

  @override
  String get dialogsScoreSubmitFailed => 'Score submission failed';

  @override
  String get titlesTutorial => 'Tutorial';

  @override
  String get titlesAchievement => 'Achievement';

  @override
  String get titlesDailyChallenge => 'Daily Challenge';

  @override
  String get titlesLevelUp => 'Level Up!';

  @override
  String get titlesNewRecord => 'New Record!';

  @override
  String get titlesAchievementUnlocked => 'Achievement Unlocked!';

  @override
  String get statsToday => 'Today';

  @override
  String get statsThisWeek => 'This Week';

  @override
  String get statsThisMonth => 'This Month';

  @override
  String get statsTotalTaps => 'Total Taps';

  @override
  String get statsCurrentLevel => 'Current Level';

  @override
  String get statsAverageTapsPerDay => 'Average Taps/Day';

  @override
  String get statsBestDay => 'Best Day';

  @override
  String get statsStreak => 'Streak';

  @override
  String get statsTaps => 'Taps';

  @override
  String get statsLevel => 'Level';

  @override
  String get statsDate => 'Date';

  @override
  String get statsNoData => 'No data available';

  @override
  String get supportContact => 'Contact';

  @override
  String get supportContactDescription => 'Bug reports and feature requests';

  @override
  String get supportPrivacyPolicy => 'Privacy Policy';

  @override
  String get supportPrivacyDescription => 'Personal information handling';

  @override
  String get supportTermsOfService => 'Terms of Service';

  @override
  String get supportTermsDescription => 'App usage conditions';

  @override
  String get appInfoAppInformation => 'App Information';

  @override
  String get appInfoCurrentLevel => 'Current Level';

  @override
  String get appInfoCurrentTapMultiplier => 'Current Tap Multiplier';

  @override
  String get appInfoVersion => 'Version';

  @override
  String get appInfoBuildNumber => 'Build Number';

  @override
  String get appInfoDeveloper => 'Developer';

  @override
  String get dataManagementDataManagement => 'Data Management';

  @override
  String get dataManagementDeleteData => 'Delete Data';

  @override
  String get dataManagementDeleteDataDescription => 'Reset all data';

  @override
  String get dataManagementDeleteDataConfirm =>
      'Are you sure you want to delete all data? This action cannot be undone.';

  @override
  String get notificationsNotifications => 'Notifications';

  @override
  String get notificationsDailyNotification => 'Daily 8 PM Notification';

  @override
  String get notificationsDailyNotificationDescription =>
      'Daily reminder to tap at 8 PM';

  @override
  String get purchasePurchase => 'Purchase';

  @override
  String get purchaseRemoveAds => 'Remove Banner Ads';

  @override
  String get purchaseRemoveAdsDescription =>
      'Hide banner ads only.\n(Video ads remain available)';

  @override
  String get purchaseRestorePurchases => 'Restore Purchases';

  @override
  String get purchaseRestorePurchasesDescription =>
      'Restore previous purchases';

  @override
  String get purchasePurchased => 'Purchased';

  @override
  String get purchaseUnavailable => 'Unavailable';

  @override
  String get purchaseLoading => 'Loading...';

  @override
  String get purchaseError =>
      'An error occurred during purchase. Please try again later.';

  @override
  String rankingScoreSubmitted(Object score) {
    return 'Score $score submitted successfully!';
  }

  @override
  String get rankingScoreSubmissionFailed => 'Score submission failed';

  @override
  String get rankingRank => 'Rank';

  @override
  String get rankingPlayer => 'Player';

  @override
  String get rankingScore => 'Score';

  @override
  String get rankingSubmitScore => 'Submit Score';

  @override
  String get rankingGameCenter => 'Game Center';

  @override
  String get rankingInApp => 'In-App';

  @override
  String get languageLanguageSettings => 'Language Settings';

  @override
  String get languageJapanese => 'Japanese';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRestartRequired => 'Please restart the app';

  @override
  String get dailyChallengeDailyChallenge => 'Daily Challenge';

  @override
  String dailyChallengeCompleted(Object reward) {
    return 'Daily challenge completed! Earned $reward taps';
  }

  @override
  String get dailyChallengeWatchAdForReward => 'Watch video to earn rewards';

  @override
  String get dailyChallengeShareScreenshot => 'Share screenshot';

  @override
  String get dailyChallengeLevel => 'Level';

  @override
  String get dailyChallengeTotalTaps => 'Total Taps';

  @override
  String get dailyChallengeTodayTaps => 'Today\'s Taps';

  @override
  String get dailyChallengeTapButton => 'TAP!';

  @override
  String get purchaseRestoreStarted => 'Purchase restoration started';

  @override
  String get purchaseRestoreFailed =>
      'Purchase restoration failed. Please try again later.';

  @override
  String get purchaseRestoreFailedRetry =>
      'Purchase restoration failed. Please try again later.';

  @override
  String get tutorialDailyChallengeDescription =>
      'Complete daily challenges to earn special rewards.';

  @override
  String levelSkipCurrentTapsMaxLevel(Object currentTaps, Object level) {
    return 'Skip to the highest level (Lv.$level) achievable with your current tap count?\n\nCurrent tap count: $currentTaps\nHighest achievable level: Lv.$level\n\nAfter skipping, your current tap count will remain the same, but your level will be set to the highest level.';
  }

  @override
  String get logsSkipApproved => 'Skip approved';

  @override
  String get logsAlreadyMaxLevel => 'Already at maximum level';

  @override
  String logsSkipError(Object error) {
    return 'Error occurred during skip process: $error';
  }

  @override
  String logsSkipErrorSnackbar(Object error) {
    return 'An error occurred during the skip process: $error';
  }

  @override
  String get weekdayMonday => 'Mon';

  @override
  String get weekdayTuesday => 'Tue';

  @override
  String get weekdayWednesday => 'Wed';

  @override
  String get weekdayThursday => 'Thu';

  @override
  String get weekdayFriday => 'Fri';

  @override
  String get weekdaySaturday => 'Sat';

  @override
  String get weekdaySunday => 'Sun';

  @override
  String get notificationAppName => 'MURITAP';

  @override
  String get notificationChannelName => 'Daily Reminder';

  @override
  String get notificationChannelDescription => 'Daily tap reminder at 8 PM';

  @override
  String get notificationChannelNameMain => 'MURITAP';

  @override
  String get notificationChannelDescriptionMain => 'MURITAP notifications';

  @override
  String get notificationMessage1 => 'Haven\'t tapped today?';

  @override
  String get notificationMessage2 => 'It\'s time to tap!';

  @override
  String get notificationMessage3 => 'Still haven\'t tapped?';

  @override
  String get notificationMessage4 => 'Let\'s tap hard today too!';

  @override
  String get notificationMessage5 => 'Level up with taps!';

  @override
  String get notificationMessage6 => 'Have you tapped today?';

  @override
  String get notificationMessage7 => 'It\'s tap time!';

  @override
  String get notificationMessage8 => 'You can still tap more!';

  @override
  String get notificationMessage9 => 'Set a new record with today\'s taps!';

  @override
  String get notificationMessage10 => 'Create a new record with taps!';

  @override
  String get notificationMessage11 => 'Have you achieved today\'s tap goal?';

  @override
  String get notificationMessage12 => 'Relieve stress with taps!';

  @override
  String get notificationMessage13 => 'Have fun tapping today too!';

  @override
  String get notificationMessage14 => 'Brain training with taps!';

  @override
  String get notificationMessage15 => 'How many taps today?';

  @override
  String get notificationMessage16 => 'Improve concentration with taps!';

  @override
  String get notificationMessage17 => 'Let\'s work hard with taps today too!';

  @override
  String get notificationMessage18 => 'Refresh with taps!';

  @override
  String get notificationMessage19 => 'Have you tapped today?';

  @override
  String get notificationMessage20 => 'Make new discoveries with taps!';

  @override
  String get titleGod => 'Tap God';

  @override
  String get titleSage => 'Tap Sage';

  @override
  String get titleMaster => 'Tap Master';

  @override
  String get titleExpert => 'Tap Expert';

  @override
  String get titleIntermediate => 'Intermediate';

  @override
  String get titleBeginner => 'Beginner';

  @override
  String get titleNovice => 'Novice';

  @override
  String get titleApprentice => 'Apprentice';

  @override
  String get titleNewbie => 'Newbie';

  @override
  String get productRemoveAds => 'Remove Banner Ads';

  @override
  String get productTap10 => '1 Tap = 10 Taps';

  @override
  String get productTap100 => '1 Tap = 100 Taps';

  @override
  String get productTap1000 => '1 Tap = 1,000 Taps';

  @override
  String get productTap1M => '1 Tap = 1 Million Taps';

  @override
  String get productTap100M => '1 Tap = 100 Million Taps';

  @override
  String get productUnknown => 'Unknown Product';

  @override
  String get productDescriptionRemoveAds =>
      'Hide only banner ads.\n(Video ads remain available)';

  @override
  String get productDescriptionTap10 =>
      'Get 10x effect per tap\n※Added permanently';

  @override
  String get productDescriptionTap100 =>
      'Get 100x effect per tap\n※Added permanently';

  @override
  String get productDescriptionTap1000 =>
      'Get 1,000x effect per tap\n※Added permanently';

  @override
  String get productDescriptionTap1M =>
      'Get 1,000,000x effect per tap\n※Added permanently';

  @override
  String get productDescriptionTap100M =>
      'Get 100,000,000x effect per tap\n※Added permanently';

  @override
  String get productDescriptionUnknown => 'Unknown effect';

  @override
  String get productPriceUnknown => 'Price unknown';

  @override
  String get ageVerificationTitle => 'Age Verification';

  @override
  String get ageVerificationContent =>
      'Purchase amounts are limited based on your age.\n\nAre you 20 years old or older?';

  @override
  String get ageVerificationYes => 'Yes';

  @override
  String get ageVerificationNo => 'No';

  @override
  String get shareDefaultText => 'Playing MURITAP!';

  @override
  String get shareAppSubject => 'MURITAP';

  @override
  String get shareAppInfo =>
      'MURITAP\n\n🎮 Addictive tap game\n📈 Level up to earn titles\n🏆 Compete in rankings\n🎁 Earn rewards by watching videos\n💰 Increase tap multiplier with purchases\n\n#MURITAP #TapGame #Game';

  @override
  String get levelDisplayNextLevel => 'To Next Level';

  @override
  String get levelDisplayLevel => 'Lv.';

  @override
  String get statsDisplayTotalTaps => 'Total Taps';

  @override
  String get statsDisplayThousand => 'K';

  @override
  String get statsDisplayTenThousand => '10K';

  @override
  String get statsChartNoData => 'No Data';

  @override
  String get statsChartTotal => 'Total';

  @override
  String get statsChartTaps => 'taps';

  @override
  String get rankingYourRecord => 'Your Record';

  @override
  String get rankingTotalTaps => 'Total Taps';

  @override
  String get rankingCurrentLevel => 'Current Level';

  @override
  String get rankingGameCenterRecord => 'GameCenter Record';

  @override
  String get rankingLastSubmitted => 'Last Submitted';

  @override
  String get rankingUploading => 'Uploading...';

  @override
  String get rankingViewInGameCenter => 'View in GameCenter';

  @override
  String get rankingSignInToGameCenter => 'Sign In to GameCenter';

  @override
  String get rankingSubmitTaps => 'Submit Tap Count';

  @override
  String get rankingGameCenterIosOnly => 'GameCenter is iOS only';

  @override
  String get rankingGameCenterDescription =>
      'Ranking features are only available on iOS devices.';

  @override
  String get rankingLeaderboard => 'Ranking';

  @override
  String get rankingAbout => 'About Ranking';

  @override
  String get rankingAboutDescription =>
      '• Total tap count is reflected in ranking\n• Score is automatically submitted when leveling up\n• You can also manually submit via \"Submit Tap Count\"\n• Ranking is automatically displayed in-app\n• \"View in GameCenter\" provides access to standard GameCenter screen';

  @override
  String get rankingShareTooltip => 'Share screenshot';

  @override
  String get rankingViewInPlayGames => 'View in Play Games';

  @override
  String get rankingSignInToPlayGames => 'Sign In to Play Games';

  @override
  String titleDisplayRemainingTaps(Object remaining, Object title) {
    return '$remaining more taps to $title';
  }

  @override
  String get titleDisplayNextTitle => 'Next Title';

  @override
  String get homeWatchVideoEarn => 'Watch video to earn';

  @override
  String homeSkipToLevel(Object level) {
    return 'Skip to Lv.$level';
  }

  @override
  String get homeLevelSkip => 'Level Skip';

  @override
  String get homeNextLevelReached => 'Next level reached!';

  @override
  String homeRemainingTapsToLevel(Object remaining) {
    return '$remaining more taps to level up!';
  }

  @override
  String get homeSkipButton => 'Skip';

  @override
  String get homeTotalTapsLabel => 'TOTAL TAPS';

  @override
  String get homeNextLevelLabel => 'NEXT LEVEL';

  @override
  String get tutorialTitle => 'Tutorial';

  @override
  String get tutorialTapToLevelUp => 'Tap to Level Up';

  @override
  String get tutorialTapToLevelUpDescription =>
      'Tap the center button to level up. Your title changes as you level up.';

  @override
  String get tutorialWatchVideoForReward => 'Watch Video for Reward';

  @override
  String get tutorialWatchVideoForRewardDescription =>
      'Watch video ads to earn 100 taps as reward.';

  @override
  String get tutorialAchievementTitle => 'Achievement';

  @override
  String get tutorialAchievementDescription =>
      'Complete various goals to unlock achievements.';

  @override
  String get achievementTitle => 'Achievement';

  @override
  String get achievementLevel10Title => 'Level 10 Achieved';

  @override
  String get achievementLevel10Description => 'Reached level 10';

  @override
  String get achievementLevel50Title => 'Level 50 Achieved';

  @override
  String get achievementLevel50Description => 'Reached level 50';

  @override
  String get achievementLevel100Title => 'Level 100 Achieved';

  @override
  String get achievementLevel100Description => 'Reached level 100';

  @override
  String get achievement1000TapsTitle => '1000 Taps Achieved';

  @override
  String get achievement1000TapsDescription => 'Tapped 1000 times';

  @override
  String get achievement10000TapsTitle => '10000 Taps Achieved';

  @override
  String get achievement10000TapsDescription => 'Tapped 10000 times';

  @override
  String dailyChallengeReward(Object taps) {
    return 'Reward: $taps taps';
  }

  @override
  String get dailyChallengeAlreadyCompleted =>
      'Today\'s daily challenge is already completed. Try again tomorrow!';

  @override
  String get dailyChallengeTitle => 'Daily Challenge';

  @override
  String get videoAdTitle => 'Video Ad';

  @override
  String get videoAdDescription =>
      'Watch video ad to earn rewards?\n\nAfter completion, you will earn 250 taps.';

  @override
  String get videoAdFailed => 'Failed to watch video. No reward earned.';

  @override
  String get videoAdCompletedWithError =>
      'Video completed! Earned 250 taps (error occurred but reward given)';

  @override
  String get watchVideoTooltip => 'Watch video to earn reward';

  @override
  String get cancel => 'Cancel';

  @override
  String get watchVideo => 'Watch';

  @override
  String get understood => 'Understood';

  @override
  String get close => 'Close';

  @override
  String get purchaseTitle => 'Purchase Items';

  @override
  String get purchaseButton => 'Purchase';

  @override
  String get settingsContact => 'Contact';

  @override
  String get settingsContactDescription => 'Bug reports and feature requests';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsPrivacyDescription => 'Personal information handling';

  @override
  String get settingsTermsOfService => 'Terms of Service';

  @override
  String get settingsTermsDescription => 'App usage conditions';

  @override
  String get settingsDeleteData => 'Delete Data';

  @override
  String get settingsDeleteDataDescription => 'Reset all data';

  @override
  String get settingsDailyNotification => 'Daily 8 PM Notification';

  @override
  String get settingsDailyNotificationDescription =>
      'Daily reminder to tap at 8 PM';

  @override
  String get settingsDataDeleteConfirmTitle => 'Confirm Data Deletion';

  @override
  String get settingsDataDeleteConfirmContent =>
      'All data (tap count, level, statistics, etc.) will be deleted.\nThis action cannot be undone.\n\nAre you sure you want to delete?';

  @override
  String get settingsDataDeleteConfirmCancel => 'Cancel';

  @override
  String get settingsDataDeleteConfirmDelete => 'Delete';

  @override
  String get settingsNotificationEnabled => 'Daily 8 PM notification enabled';

  @override
  String get settingsNotificationDisabled => 'Daily 8 PM notification disabled';

  @override
  String get dailyChallengeCompletedShort => 'Completed';

  @override
  String get appTitle => 'MURITAP';

  @override
  String get tutorialDailyChallengeTitle => 'Daily Challenge';

  @override
  String get settingsAppInfoTitle => 'App Information';

  @override
  String get settingsCurrentLevel => 'Current Level';

  @override
  String get settingsCurrentTapMultiplier => 'Current Tap Multiplier';

  @override
  String get settingsTodayStatsTitle => 'Today\'s Statistics';

  @override
  String get settingsTodayTaps => 'Today\'s Taps';

  @override
  String get settingsTodayActualTaps => 'Today\'s Actual Taps';

  @override
  String get settingsTotalTaps => 'Total Taps';

  @override
  String get settingsCurrentLevelLabel => 'Current Level';

  @override
  String get settingsWeeklyRecordTitle => 'This Week\'s Record';

  @override
  String get settingsMonthlyRecordTitle => 'Past 30 Days Record';

  @override
  String get settingsPurchaseDescription =>
      'You can purchase features such as ad removal and tap multiplier increase.';

  @override
  String get settingsPurchased => 'Purchased';

  @override
  String homeSkipSuccess(Object level) {
    return 'Skipped to Lv.$level!';
  }

  @override
  String get homeAlreadyMaxLevel =>
      'You have already reached the maximum level.';

  @override
  String homeSkipError(Object error) {
    return 'An error occurred during skip process: $error';
  }

  @override
  String get homeVideoAdSuccess =>
      'Video watching completed! You earned 250 taps';

  @override
  String get homeVideoAdLoading =>
      'Video advertisement is loading. Please wait and try again.';

  @override
  String homeLevelUpNotification(Object level) {
    return 'LEVEL UP! Lv.$level';
  }

  @override
  String get homeAchievementLevel10Title => 'Level 10 Achieved';

  @override
  String get homeAchievementLevel10Description => 'Reached level 10';

  @override
  String get homeAchievementLevel50Title => 'Level 50 Achieved';

  @override
  String get homeAchievementLevel50Description => 'Reached level 50';

  @override
  String get homeAchievementLevel100Title => 'Level 100 Achieved';

  @override
  String get homeAchievementLevel100Description => 'Reached level 100';

  @override
  String get homeAchievement1000TapsTitle => '1000 Taps Achieved';

  @override
  String get homeAchievement1000TapsDescription => 'Tapped 1000 times';

  @override
  String get homeAchievement10000TapsTitle => '10000 Taps Achieved';

  @override
  String get homeAchievement10000TapsDescription => 'Tapped 10000 times';

  @override
  String get settingsEmailAppError => 'Could not open email app';

  @override
  String settingsEmailSendError(Object error) {
    return 'Email sending error: $error';
  }

  @override
  String get settingsDataDeleteSuccess => 'All data has been deleted';

  @override
  String settingsDataDeleteError(Object error) {
    return 'An error occurred while deleting data: $error';
  }

  @override
  String settingsNotificationSettingError(Object error) {
    return 'Notification setting error: $error';
  }

  @override
  String get settingsPurchaseFailed =>
      'Purchase failed. Please try again later.';

  @override
  String settingsPurchaseSuccess(Object productName) {
    return '$productName purchased successfully!';
  }

  @override
  String purchaseSuccess(Object productName) {
    return '$productName purchased successfully!';
  }

  @override
  String get purchaseFailed => 'Purchase failed. Please try again later.';

  @override
  String get purchaseTap10 => '1 Tap = 10 Taps';

  @override
  String get purchaseTap100 => '1 Tap = 100 Taps';

  @override
  String get purchaseTap1000 => '1 Tap = 1000 Taps';

  @override
  String get purchaseTap10Description =>
      'Get 10 taps effect with 1 tap\n※Permanently added';

  @override
  String get purchaseTap100Description =>
      'Get 100 taps effect with 1 tap\n※Permanently added';

  @override
  String get purchaseTap1000Description =>
      'Get 1000 taps effect with 1 tap\n※Permanently added';

  @override
  String get priceRemoveAds => '\$0.99';

  @override
  String get priceTap10 => '\$0.99';

  @override
  String get priceTap100 => '\$2.99';

  @override
  String get priceTap1000 => '\$9.99';

  @override
  String get priceUnknown => 'Price unknown';

  @override
  String get currency => 'USD';

  @override
  String get currencySymbol => '\$';

  @override
  String get notificationGeneralChannelName => 'MURITAP';

  @override
  String get notificationGeneralChannelDescription => 'MURITAP notifications';

  @override
  String homeShareText(Object level, Object totalTaps) {
    return 'Achieved level $level with $totalTaps total taps in MURITAP!\nJoin the ranking too!\nApp download (iOS):\nhttps://apps.apple.com/jp/developer/jin-mizoi/id1548623319';
  }
}
