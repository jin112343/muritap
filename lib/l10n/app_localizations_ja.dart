// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'MURITAP';

  @override
  String get navigationRanking => 'ランキング';

  @override
  String get navigationHome => 'ホーム';

  @override
  String get navigationSettings => '設定';

  @override
  String get homeLevel => 'レベル';

  @override
  String get homeTotalTaps => '総タップ数';

  @override
  String get homeTodayTaps => '今日のタップ数';

  @override
  String get homeTapButton => 'タップ！';

  @override
  String get homeLevelUp => 'レベルアップ！';

  @override
  String get homeNewRecord => '新記録！';

  @override
  String get homeAchievement => '実績解除！';

  @override
  String get homeRatingDialogTitle => '100回タップ達成！';

  @override
  String get homeRatingDialogContent =>
      '🎉 おめでとうございます！100回タップを達成しました！\n\nこのアプリを楽しんでいただけましたか？\nもし良かったら、App Storeで5つ星評価をしていただけませんか？\n\nあなたの評価が、アプリの改善に役立ちます。';

  @override
  String get homeRatingDialogLater => '後で';

  @override
  String get homeRatingDialogRateOnAppStore => 'App Storeで評価';

  @override
  String get rankingTitle => 'ランキング';

  @override
  String get rankingSignIn => 'Game Centerにサインイン';

  @override
  String get rankingShowLeaderboard => 'リーダーボードを表示';

  @override
  String get rankingInAppRanking => 'アプリ内ランキング';

  @override
  String get rankingShare => '共有';

  @override
  String rankingShareText(Object level, Object taps) {
    return 'MURITAPで\nレベル$levelで\n総タップ数$taps回達成！\nあなたもランキングに参加しよう！\nアプリダウンロードはこちら(ios):\nhttps://apps.apple.com/jp/developer/jin-mizoi/id1548623319';
  }

  @override
  String get rankingNoData => 'ランキングデータがありません';

  @override
  String get rankingLoading => '読み込み中...';

  @override
  String get rankingError => 'エラーが発生しました';

  @override
  String get settingsTabsSettings => '設定';

  @override
  String get settingsTabsStats => '統計';

  @override
  String get settingsTabsPurchase => '購入';

  @override
  String get settingsGeneralTitle => '一般設定';

  @override
  String get settingsGeneralDailyNotification => '毎日通知（20時）';

  @override
  String get settingsGeneralNotificationDescription => '毎日のプレイリマインダーを受け取る';

  @override
  String get settingsGeneralAppInfo => 'アプリ情報';

  @override
  String get settingsGeneralVersion => 'バージョン';

  @override
  String get settingsGeneralBuildNumber => 'ビルド番号';

  @override
  String get settingsGeneralDeveloper => '開発者';

  @override
  String get settingsGeneralPrivacyPolicy => 'プライバシーポリシー';

  @override
  String get settingsGeneralTermsOfService => '利用規約';

  @override
  String get settingsStatsTitle => '統計';

  @override
  String get settingsStatsToday => '今日';

  @override
  String get settingsStatsThisWeek => '今週';

  @override
  String get settingsStatsThisMonth => '今月';

  @override
  String get settingsStatsTotalTaps => '総タップ数';

  @override
  String get settingsStatsCurrentLevel => '現在のレベル';

  @override
  String get settingsStatsAverageTapsPerDay => '1日平均タップ数';

  @override
  String get settingsStatsBestDay => '最高記録日';

  @override
  String get settingsStatsStreak => '連続記録';

  @override
  String get settingsPurchaseTitle => '課金商品';

  @override
  String get settingsPurchaseRemoveAds => '広告を削除';

  @override
  String get settingsPurchaseRemoveAdsDescription => '広告なしでゲームを楽しむ';

  @override
  String get settingsPurchaseRestore => '購入を復元';

  @override
  String get settingsPurchasePurchase => '購入';

  @override
  String get settingsPurchasePurchased => '購入済み';

  @override
  String get settingsPurchaseUnavailable => '利用不可';

  @override
  String get settingsPurchaseLoading => '読み込み中...';

  @override
  String get settingsPurchaseError => '購入処理でエラーが発生しました。しばらく時間をおいて再度お試しください。';

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'キャンセル';

  @override
  String get commonClose => '閉じる';

  @override
  String get commonLoading => '読み込み中...';

  @override
  String get commonError => 'エラー';

  @override
  String get commonSuccess => '成功';

  @override
  String get commonRetry => '再試行';

  @override
  String get commonYes => 'はい';

  @override
  String get commonNo => 'いいえ';

  @override
  String get commonDelete => '削除';

  @override
  String get commonRestore => '復元';

  @override
  String get commonSkip => 'スキップ';

  @override
  String get commonWatch => '視聴する';

  @override
  String get commonUnderstand => '理解しました';

  @override
  String get commonRestart => '再起動';

  @override
  String get dialogsLevelSkipTitle => 'レベルスキップ';

  @override
  String get dialogsLevelSkipContent => '次のレベルにスキップしますか？スキップチケットが消費されます。';

  @override
  String get dialogsLevelSkipSkip => 'スキップ';

  @override
  String get dialogsLevelSkipCancel => 'キャンセル';

  @override
  String dialogsLevelSkipSuccess(Object level) {
    return 'Lv.$levelまでスキップしました！';
  }

  @override
  String get dialogsLevelSkipMaxLevel => '既に最高レベルに到達しています。';

  @override
  String dialogsLevelSkipError(Object error) {
    return 'スキップ処理でエラーが発生しました: $error';
  }

  @override
  String get dialogsDailyChallengeAlreadyCompleted =>
      '今日のデイリーチャレンジは既に完了済みです。明日また挑戦してください！';

  @override
  String dialogsDailyChallengeCompleted(Object reward) {
    return 'デイリーチャレンジ完了！$rewardタップを獲得しました';
  }

  @override
  String get dialogsDailyChallengeNotAvailable => 'デイリーチャレンジはまだ利用できません';

  @override
  String get dialogsVideoAdTitle => '動画広告';

  @override
  String get dialogsVideoAdContent =>
      '動画広告を視聴して報酬を獲得しますか？\n\n視聴完了後、250タップを獲得できます。';

  @override
  String get dialogsVideoAdWatch => '視聴する';

  @override
  String get dialogsVideoAdCancel => 'キャンセル';

  @override
  String get dialogsVideoAdSuccess => '動画視聴完了！250タップを獲得しました';

  @override
  String get dialogsVideoAdFailed => '動画視聴に失敗しました。報酬は獲得できませんでした。';

  @override
  String get dialogsVideoAdSuccessWithError =>
      '動画視聴完了！250タップを獲得しました（エラーが発生しましたが報酬は付与されます）';

  @override
  String get dialogsVideoAdLoading => '動画広告の読み込み中です。しばらく待ってから再試行してください。';

  @override
  String get dialogsDataDeleteTitle => 'データ削除の確認';

  @override
  String get dialogsDataDeleteContent => 'すべてのデータを削除してもよろしいですか？この操作は取り消せません。';

  @override
  String get dialogsDataDeleteDelete => '削除';

  @override
  String get dialogsDataDeleteCancel => 'キャンセル';

  @override
  String get dialogsDataDeleteSuccess => 'すべてのデータを削除しました';

  @override
  String dialogsDataDeleteError(Object error) {
    return 'データ削除中にエラーが発生しました: $error';
  }

  @override
  String get dialogsLanguageChangeTitle => '言語を変更しますか？';

  @override
  String get dialogsLanguageChangeContent => '言語を変更するには、アプリを再起動する必要があります。';

  @override
  String get dialogsLanguageChangeRestart => '再起動';

  @override
  String get dialogsLanguageChangeCancel => 'キャンセル';

  @override
  String dialogsPurchaseSuccess(Object productName) {
    return '$productNameを購入しました！';
  }

  @override
  String get dialogsPurchaseFailed => '購入に失敗しました。しばらく時間をおいて再度お試しください。';

  @override
  String get dialogsPurchaseError => '購入処理でエラーが発生しました。しばらく時間をおいて再度お試しください。';

  @override
  String get dialogsPurchaseRestoreStarted => '購入履歴の復元を開始しました';

  @override
  String get dialogsPurchaseRestoreFailed =>
      '購入履歴の復元に失敗しました。しばらく時間をおいて再度お試しください。';

  @override
  String get dialogsNotificationEnabled => '毎日20時の通知を有効にしました';

  @override
  String get dialogsNotificationDisabled => '毎日20時の通知を無効にしました';

  @override
  String dialogsNotificationError(Object error) {
    return '通知設定エラー: $error';
  }

  @override
  String get dialogsEmailError => 'メールアプリを開けませんでした';

  @override
  String dialogsEmailSendError(Object error) {
    return 'メール送信エラー: $error';
  }

  @override
  String dialogsScoreSubmitSuccess(Object score) {
    return 'タップ回数 $score回 を送信しました！';
  }

  @override
  String get dialogsScoreSubmitFailed => 'スコアの送信に失敗しました';

  @override
  String get titlesTutorial => 'チュートリアル';

  @override
  String get titlesAchievement => 'アチーブメント';

  @override
  String get titlesDailyChallenge => 'デイリーチャレンジ';

  @override
  String get titlesLevelUp => 'レベルアップ！';

  @override
  String get titlesNewRecord => '新記録！';

  @override
  String get titlesAchievementUnlocked => '実績解除！';

  @override
  String get statsToday => '今日';

  @override
  String get statsThisWeek => '今週';

  @override
  String get statsThisMonth => '今月';

  @override
  String get statsTotalTaps => '総タップ数';

  @override
  String get statsCurrentLevel => '現在のレベル';

  @override
  String get statsAverageTapsPerDay => '1日平均タップ数';

  @override
  String get statsBestDay => '最高記録日';

  @override
  String get statsStreak => '連続記録';

  @override
  String get statsTaps => 'タップ';

  @override
  String get statsLevel => 'レベル';

  @override
  String get statsDate => '日付';

  @override
  String get statsNoData => 'データがありません';

  @override
  String get supportContact => 'お問い合わせ';

  @override
  String get supportContactDescription => 'バグ報告や機能要望';

  @override
  String get supportPrivacyPolicy => 'プライバシーポリシー';

  @override
  String get supportPrivacyDescription => '個人情報の取り扱い';

  @override
  String get supportTermsOfService => '利用規約';

  @override
  String get supportTermsDescription => 'アプリの利用条件';

  @override
  String get appInfoAppInformation => 'アプリ情報';

  @override
  String get appInfoCurrentLevel => '現在のレベル';

  @override
  String get appInfoCurrentTapMultiplier => '現在のタップ倍率';

  @override
  String get appInfoVersion => 'バージョン';

  @override
  String get appInfoBuildNumber => 'ビルド番号';

  @override
  String get appInfoDeveloper => '開発者';

  @override
  String get dataManagementDataManagement => 'データ管理';

  @override
  String get dataManagementDeleteData => 'データを削除';

  @override
  String get dataManagementDeleteDataDescription => 'すべてのデータをリセット';

  @override
  String get dataManagementDeleteDataConfirm =>
      'すべてのデータを削除してもよろしいですか？この操作は取り消せません。';

  @override
  String get notificationsNotifications => '通知';

  @override
  String get notificationsDailyNotification => '毎日20時の通知';

  @override
  String get notificationsDailyNotificationDescription => '毎日20時にタップを促す通知';

  @override
  String get purchasePurchase => '購入';

  @override
  String get purchaseRemoveAds => 'バナー広告削除';

  @override
  String get purchaseRemoveAdsDescription =>
      'バナー広告のみを非表示にします。\n（動画広告は引き続き利用可能）';

  @override
  String get purchaseRestorePurchases => '購入履歴を復元';

  @override
  String get purchaseRestorePurchasesDescription => '以前の購入を復元します';

  @override
  String get purchasePurchased => '購入済み';

  @override
  String get purchaseUnavailable => '利用不可';

  @override
  String get purchaseLoading => '読み込み中...';

  @override
  String get purchaseError => '購入処理でエラーが発生しました。しばらく時間をおいて再度お試しください。';

  @override
  String rankingScoreSubmitted(Object score) {
    return 'タップ回数 $score回 を送信しました！';
  }

  @override
  String get rankingScoreSubmissionFailed => 'スコアの送信に失敗しました';

  @override
  String get rankingRank => '順位';

  @override
  String get rankingPlayer => 'プレイヤー';

  @override
  String get rankingScore => 'スコア';

  @override
  String get rankingSubmitScore => 'スコア送信';

  @override
  String get rankingGameCenter => 'Game Center';

  @override
  String get rankingInApp => 'アプリ内';

  @override
  String get languageLanguageSettings => '言語設定';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRestartRequired => 'アプリを再起動してください';

  @override
  String get dailyChallengeDailyChallenge => 'デイリーチャレンジ';

  @override
  String dailyChallengeCompleted(Object reward) {
    return 'デイリーチャレンジ完了！$rewardタップを獲得しました';
  }

  @override
  String get dailyChallengeWatchAdForReward => '動画を見て報酬を獲得';

  @override
  String get dailyChallengeShareScreenshot => 'スクリーンショットを共有';

  @override
  String get dailyChallengeLevel => 'レベル';

  @override
  String get dailyChallengeTotalTaps => '累計タップ数';

  @override
  String get dailyChallengeTodayTaps => '今日のタップ数';

  @override
  String get dailyChallengeTapButton => 'タップ！';

  @override
  String get purchaseRestoreStarted => '購入履歴の復元を開始しました';

  @override
  String get purchaseRestoreFailed => '購入履歴の復元に失敗しました。しばらく時間をおいて再度お試しください。';

  @override
  String get purchaseRestoreFailedRetry =>
      '購入履歴の復元に失敗しました。しばらく時間をおいて再度お試しください。';

  @override
  String get tutorialDailyChallengeDescription =>
      '毎日のチャレンジをクリアして特別な報酬を獲得しましょう。';

  @override
  String levelSkipCurrentTapsMaxLevel(Object currentTaps, Object level) {
    return '現在のタップ数で行ける最高レベル（Lv.$level）までスキップしますか？\n\n現在のタップ数: $currentTaps\n到達可能な最高レベル: Lv.$level\n\nスキップ後は、現在のタップ数はそのままで、レベルだけが最高レベルに設定されます。';
  }

  @override
  String get logsSkipApproved => 'スキップが承認されました';

  @override
  String get logsAlreadyMaxLevel => '既に最高レベルに到達しています';

  @override
  String logsSkipError(Object error) {
    return 'スキップ処理でエラーが発生: $error';
  }

  @override
  String logsSkipErrorSnackbar(Object error) {
    return 'スキップ処理でエラーが発生しました: $error';
  }

  @override
  String get weekdayMonday => '月';

  @override
  String get weekdayTuesday => '火';

  @override
  String get weekdayWednesday => '水';

  @override
  String get weekdayThursday => '木';

  @override
  String get weekdayFriday => '金';

  @override
  String get weekdaySaturday => '土';

  @override
  String get weekdaySunday => '日';

  @override
  String get notificationAppName => 'MURITAP';

  @override
  String get notificationChannelName => '毎日のリマインダー';

  @override
  String get notificationChannelDescription => '毎日20時のタップリマインダー';

  @override
  String get notificationChannelNameMain => 'MURITAP';

  @override
  String get notificationChannelDescriptionMain => 'MURITAPの通知';

  @override
  String get notificationMessage1 => '今日はタップしないの？';

  @override
  String get notificationMessage2 => 'タップする時間ですよ！';

  @override
  String get notificationMessage3 => 'まだタップしてないの？';

  @override
  String get notificationMessage4 => '今日も頑張ってタップしよう！';

  @override
  String get notificationMessage5 => 'タップでレベルアップしよう！';

  @override
  String get notificationMessage6 => '今日のタップは済みましたか？';

  @override
  String get notificationMessage7 => 'タップの時間です！';

  @override
  String get notificationMessage8 => 'まだまだタップできるよ！';

  @override
  String get notificationMessage9 => '今日もタップで記録更新！';

  @override
  String get notificationMessage10 => 'タップで新しい記録を作ろう！';

  @override
  String get notificationMessage11 => '今日のタップ目標は達成しましたか？';

  @override
  String get notificationMessage12 => 'タップでストレス発散！';

  @override
  String get notificationMessage13 => '今日もタップで楽しく！';

  @override
  String get notificationMessage14 => 'タップで脳トレ！';

  @override
  String get notificationMessage15 => '今日のタップは何回？';

  @override
  String get notificationMessage16 => 'タップで集中力アップ！';

  @override
  String get notificationMessage17 => '今日もタップで頑張ろう！';

  @override
  String get notificationMessage18 => 'タップでリフレッシュ！';

  @override
  String get notificationMessage19 => '今日のタップは済みましたか？';

  @override
  String get notificationMessage20 => 'タップで新しい発見を！';

  @override
  String get titleGod => 'タップ神';

  @override
  String get titleSage => 'タップ仙人';

  @override
  String get titleMaster => 'タップマスター';

  @override
  String get titleExpert => 'タップ名人';

  @override
  String get titleIntermediate => '中級者';

  @override
  String get titleBeginner => '初級者';

  @override
  String get titleNovice => '初心者';

  @override
  String get titleApprentice => '見習い';

  @override
  String get titleNewbie => '新米';

  @override
  String get productRemoveAds => 'バナー広告削除';

  @override
  String get productTap10 => '1タップ10回';

  @override
  String get productTap100 => '1タップ100回';

  @override
  String get productTap1000 => '1タップ1000回';

  @override
  String get productTap1M => '1タップ100万回';

  @override
  String get productTap100M => '1タップ1億回';

  @override
  String get productUnknown => '不明な商品';

  @override
  String get productDescriptionRemoveAds => 'バナー広告のみを非表示にします。\n（動画広告は引き続き利用可能）';

  @override
  String get productDescriptionTap10 => '1回のタップで10回分の効果を獲得\n※永久に加算されます';

  @override
  String get productDescriptionTap100 => '1回のタップで100回分の効果を獲得\n※永久に加算されます';

  @override
  String get productDescriptionTap1000 => '1回のタップで1000回分の効果を獲得\n※永久に加算されます';

  @override
  String get productDescriptionTap1M => '1回のタップで100万回分の効果を獲得\n※永久に加算されます';

  @override
  String get productDescriptionTap100M => '1回のタップで1億回分の効果を獲得\n※永久に加算されます';

  @override
  String get productDescriptionUnknown => '効果不明';

  @override
  String get productPriceUnknown => 'Price unknown';

  @override
  String get ageVerificationTitle => 'あなたの年齢選択';

  @override
  String get ageVerificationContent =>
      'あそんでいる年齢（ねんれい）によって買（か）える金額（きんがく）がきまっています。\n\n20歳以上ですか？';

  @override
  String get ageVerificationYes => 'はい';

  @override
  String get ageVerificationNo => 'いいえ';

  @override
  String get shareDefaultText => 'MURITAPで遊んでいます！';

  @override
  String get shareAppSubject => 'MURITAP';

  @override
  String get shareAppInfo =>
      'MURITAP\n\n🎮 中毒性抜群のタップゲーム\n📈 レベルアップで称号獲得\n🏆 ランキングで競争\n🎁 動画視聴で報酬獲得\n💰 課金でタップ倍率アップ\n\n#MURITAP #タップゲーム #ゲーム';

  @override
  String get levelDisplayNextLevel => '次のレベルまで';

  @override
  String get levelDisplayLevel => 'Lv.';

  @override
  String get statsDisplayTotalTaps => '累積タップ数';

  @override
  String get statsDisplayThousand => '千';

  @override
  String get statsDisplayTenThousand => '万';

  @override
  String get statsChartNoData => 'データがありません';

  @override
  String get statsChartTotal => '合計';

  @override
  String get statsChartTaps => 'タップ';

  @override
  String get rankingYourRecord => 'あなたの記録';

  @override
  String get rankingTotalTaps => '累積タップ数';

  @override
  String get rankingCurrentLevel => '現在レベル';

  @override
  String get rankingGameCenterRecord => 'GameCenter記録';

  @override
  String get rankingLastSubmitted => '最後に送信';

  @override
  String get rankingUploading => '送信中...';

  @override
  String get rankingViewInGameCenter => 'GameCenterで見る';

  @override
  String get rankingSignInToGameCenter => 'GameCenterにサインイン';

  @override
  String get rankingSubmitTaps => 'タップ回数を送信';

  @override
  String get rankingGameCenterIosOnly => 'GameCenterはiOSのみ対応';

  @override
  String get rankingGameCenterDescription => 'タップ回数のランキング機能はiOSデバイスでのみ利用できます。';

  @override
  String get rankingLeaderboard => 'ランキング';

  @override
  String get rankingAbout => 'ランキングについて';

  @override
  String get rankingAboutDescription =>
      '• 累積タップ数がランキングに反映されます\n• レベルアップ時に自動でスコアが送信されます\n• 手動でも「タップ回数を送信」で送信できます\n• アプリ内でランキングが自動表示されます\n• 「GameCenterで見る」で標準のGameCenter画面も利用可能';

  @override
  String get rankingShareTooltip => 'スクリーンショットを共有';

  @override
  String get rankingViewInPlayGames => 'Play Gamesで見る';

  @override
  String get rankingSignInToPlayGames => 'Play Gamesにサインイン';

  @override
  String titleDisplayRemainingTaps(Object remaining, Object title) {
    return '$titleまで残り$remainingタップ';
  }

  @override
  String get titleDisplayNextTitle => '次の称号';

  @override
  String get homeWatchVideoEarn => '動画を見て';

  @override
  String homeSkipToLevel(Object level) {
    return 'Lv.$levelにスキップ';
  }

  @override
  String get homeLevelSkip => 'レベルスキップ';

  @override
  String get homeNextLevelReached => '次のレベルに到達済み！';

  @override
  String homeRemainingTapsToLevel(Object remaining) {
    return 'あと$remaining回でレベルアップ！';
  }

  @override
  String get homeSkipButton => 'スキップ';

  @override
  String get homeTotalTapsLabel => 'TOTAL TAPS';

  @override
  String get homeNextLevelLabel => 'NEXT LEVEL';

  @override
  String get tutorialTitle => 'チュートリアル';

  @override
  String get tutorialTapToLevelUp => 'タップしてレベルアップ';

  @override
  String get tutorialTapToLevelUpDescription =>
      '中央のボタンをタップしてレベルを上げましょう。レベルが上がると称号が変わります。';

  @override
  String get tutorialWatchVideoForReward => '動画で報酬獲得';

  @override
  String get tutorialWatchVideoForRewardDescription =>
      '動画広告を視聴して100タップの報酬を獲得できます。';

  @override
  String get tutorialAchievementTitle => 'アチーブメント';

  @override
  String get tutorialAchievementDescription => '様々な目標を達成してアチーブメントを解除しましょう。';

  @override
  String get achievementTitle => 'アチーブメント';

  @override
  String get achievementLevel10Title => 'レベル10達成';

  @override
  String get achievementLevel10Description => 'レベル10に到達しました';

  @override
  String get achievementLevel50Title => 'レベル50達成';

  @override
  String get achievementLevel50Description => 'レベル50に到達しました';

  @override
  String get achievementLevel100Title => 'レベル100達成';

  @override
  String get achievementLevel100Description => 'レベル100に到達しました';

  @override
  String get achievement1000TapsTitle => '1000タップ達成';

  @override
  String get achievement1000TapsDescription => '1000回タップしました';

  @override
  String get achievement10000TapsTitle => '10000タップ達成';

  @override
  String get achievement10000TapsDescription => '10000回タップしました';

  @override
  String dailyChallengeReward(Object taps) {
    return '報酬: $tapsタップ';
  }

  @override
  String get dailyChallengeAlreadyCompleted =>
      '今日のデイリーチャレンジは既に完了済みです。明日また挑戦してください！';

  @override
  String get dailyChallengeTitle => 'デイリーチャレンジ';

  @override
  String get videoAdTitle => '動画広告';

  @override
  String get videoAdDescription =>
      '動画広告を視聴して報酬を獲得しますか？\n\n視聴完了後、250タップを獲得できます。';

  @override
  String get videoAdFailed => '動画視聴に失敗しました。報酬は獲得できませんでした。';

  @override
  String get videoAdCompletedWithError =>
      '動画視聴完了！250タップを獲得しました（エラーが発生しましたが報酬は付与されます）';

  @override
  String get watchVideoTooltip => '動画を見て報酬を獲得';

  @override
  String get cancel => 'キャンセル';

  @override
  String get watchVideo => '視聴する';

  @override
  String get understood => '理解しました';

  @override
  String get close => '閉じる';

  @override
  String get purchaseTitle => '課金商品';

  @override
  String get purchaseButton => '購入する';

  @override
  String get settingsContact => 'お問い合わせ';

  @override
  String get settingsContactDescription => 'バグ報告や機能要望';

  @override
  String get settingsPrivacyPolicy => 'プライバシーポリシー';

  @override
  String get settingsPrivacyDescription => '個人情報の取り扱い';

  @override
  String get settingsTermsOfService => '利用規約';

  @override
  String get settingsTermsDescription => 'アプリの利用条件';

  @override
  String get settingsDeleteData => 'データを削除';

  @override
  String get settingsDeleteDataDescription => 'すべてのデータをリセット';

  @override
  String get settingsDailyNotification => '毎日20時の通知';

  @override
  String get settingsDailyNotificationDescription => '毎日20時にタップを促す通知';

  @override
  String get settingsDataDeleteConfirmTitle => 'データ削除の確認';

  @override
  String get settingsDataDeleteConfirmContent =>
      'すべてのデータ（タップ数、レベル、統計など）が削除されます。\nこの操作は取り消すことができません。\n\n本当に削除しますか？';

  @override
  String get settingsDataDeleteConfirmCancel => 'キャンセル';

  @override
  String get settingsDataDeleteConfirmDelete => '削除';

  @override
  String get settingsNotificationEnabled => '毎日20時の通知を有効にしました';

  @override
  String get settingsNotificationDisabled => '毎日20時の通知を無効にしました';

  @override
  String get dailyChallengeCompletedShort => '完了';

  @override
  String get appTitle => 'MURITAP';

  @override
  String get tutorialDailyChallengeTitle => 'デイリーチャレンジ';

  @override
  String get settingsAppInfoTitle => 'アプリ情報';

  @override
  String get settingsCurrentLevel => '現在のレベル';

  @override
  String get settingsCurrentTapMultiplier => '現在のタップ倍率';

  @override
  String get settingsTodayStatsTitle => '今日の統計';

  @override
  String get settingsTodayTaps => '今日のタップ数';

  @override
  String get settingsTodayActualTaps => '今日の実際のタップ数';

  @override
  String get settingsTotalTaps => '総タップ数';

  @override
  String get settingsCurrentLevelLabel => '現在のレベル';

  @override
  String get settingsWeeklyRecordTitle => '今週の記録（月曜日から）';

  @override
  String get settingsMonthlyRecordTitle => '過去30日間の記録';

  @override
  String get settingsPurchaseDescription => '広告削除やタップ倍率アップなどの機能を購入できます。';

  @override
  String get settingsPurchased => '購入済み';

  @override
  String homeSkipSuccess(Object level) {
    return 'Lv.$levelまでスキップしました！';
  }

  @override
  String get homeAlreadyMaxLevel => '既に最高レベルに到達しています。';

  @override
  String homeSkipError(Object error) {
    return 'スキップ処理でエラーが発生しました: $error';
  }

  @override
  String get homeVideoAdSuccess => '動画視聴完了！250タップを獲得しました';

  @override
  String get homeVideoAdLoading => '動画広告の読み込み中です。しばらく待ってから再試行してください。';

  @override
  String homeLevelUpNotification(Object level) {
    return 'LEVEL UP! Lv.$level';
  }

  @override
  String get homeAchievementLevel10Title => 'レベル10達成';

  @override
  String get homeAchievementLevel10Description => 'レベル10に到達しました';

  @override
  String get homeAchievementLevel50Title => 'レベル50達成';

  @override
  String get homeAchievementLevel50Description => 'レベル50に到達しました';

  @override
  String get homeAchievementLevel100Title => 'レベル100達成';

  @override
  String get homeAchievementLevel100Description => 'レベル100に到達しました';

  @override
  String get homeAchievement1000TapsTitle => '1000タップ達成';

  @override
  String get homeAchievement1000TapsDescription => '1000回タップしました';

  @override
  String get homeAchievement10000TapsTitle => '10000タップ達成';

  @override
  String get homeAchievement10000TapsDescription => '10000回タップしました';

  @override
  String get settingsEmailAppError => 'メールアプリを開けませんでした';

  @override
  String settingsEmailSendError(Object error) {
    return 'メール送信エラー: $error';
  }

  @override
  String get settingsDataDeleteSuccess => 'すべてのデータを削除しました';

  @override
  String settingsDataDeleteError(Object error) {
    return 'データ削除中にエラーが発生しました: $error';
  }

  @override
  String settingsNotificationSettingError(Object error) {
    return '通知設定エラー: $error';
  }

  @override
  String get settingsPurchaseFailed => '購入に失敗しました。しばらく時間をおいて再度お試しください。';

  @override
  String settingsPurchaseSuccess(Object productName) {
    return '$productNameを購入しました！';
  }

  @override
  String purchaseSuccess(Object productName) {
    return '$productNameを購入しました！';
  }

  @override
  String get purchaseFailed => '購入に失敗しました。しばらく時間をおいて再度お試しください。';

  @override
  String get purchaseTap10 => '1タップ10回';

  @override
  String get purchaseTap100 => '1タップ100回';

  @override
  String get purchaseTap1000 => '1タップ1000回';

  @override
  String get purchaseTap10Description => '1回のタップで10回分の効果を獲得\n※永久に加算されます';

  @override
  String get purchaseTap100Description => '1回のタップで100回分の効果を獲得\n※永久に加算されます';

  @override
  String get purchaseTap1000Description => '1回のタップで1000回分の効果を獲得\n※永久に加算されます';

  @override
  String get priceRemoveAds => '100円';

  @override
  String get priceTap10 => '100円';

  @override
  String get priceTap100 => '300円';

  @override
  String get priceTap1000 => '1,000円';

  @override
  String get priceUnknown => '価格不明';

  @override
  String get currency => 'JPY';

  @override
  String get currencySymbol => '¥';

  @override
  String get notificationGeneralChannelName => 'MURITAP';

  @override
  String get notificationGeneralChannelDescription => 'MURITAPの通知';

  @override
  String homeShareText(Object level, Object totalTaps) {
    return 'MURITAPで\nレベル$levelで\n総タップ数$totalTaps回達成！\nあなたもランキングに参加しよう！\nアプリダウンロードはこちら(ios):\nhttps://apps.apple.com/jp/developer/jin-mizoi/id1548623319';
  }
}
