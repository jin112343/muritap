/// アプリケーション設定クラス
/// 機密性を保つため、設定値を一元管理
class AppConfig {
  // アプリケーション基本情報
  static const String appName = '絶対ムリタップ';
  static const String appVersion = '1.0.0';
  
  // データ保存キー
  static const String keyTotalTaps = 'total_taps';
  static const String keyCurrentLevel = 'current_level';
  static const String keyHighestLevel = 'highest_level';
  
  // レベル計算パラメータ
  static const int baseTaps = 10;
  static const double growthRate = 2.0; // 1.55から2.0に変更
  static const int maxLevel = 999;
  
  // 広告設定
  static const String bannerAdUnitIdAndroid = 'ca-app-pub-3940256099942544/6300978111'; // Android テスト用
  static const String bannerAdUnitIdIOS = 'ca-app-pub-3940256099942544/2934735716'; // iOS テスト用
  
  // リワード広告設定
  static const String rewardedAdUnitIdAndroid = 'ca-app-pub-3940256099942544/5224354917'; // Android テスト用
  static const String rewardedAdUnitIdIOS = 'ca-app-pub-3940256099942544/1712485313'; // iOS テスト用
  
  // 外部リンク
  static const String contactEmail = 'support@impossibletap.com';
  static const String supportEmail = 'support@impossibletap.com';
  static const String privacyPolicyUrl = 'https://jinpost.wordpress.com/2025/07/30/%e7%b5%b6%e5%af%be%e3%83%a0%e3%83%aa%e3%82%bf%e3%83%83%e3%83%97-%e3%83%97%e3%83%a9%e3%82%a4%e3%83%90%e3%82%b7%e3%83%bc%e3%83%9d%e3%83%aa%e3%82%b7%e3%83%bc/';
  static const String termsOfServiceUrl = 'https://jinpost.wordpress.com/2025/07/30/%e5%88%a9%e7%94%a8%e8%a6%8f%e7%b4%84-%e5%88%a9%e7%94%a8%e8%a6%8f%e7%b4%84-%e7%b5%b6%e5%af%be%e3%83%a0%e3%83%aa%e3%82%bf%e3%83%83%e3%83%97/';
  
  // GameCenter設定
  static const String leaderboardId = 'impossible_tap_leaderboard';
  
  // アニメーション設定
  static const Duration levelUpAnimationDuration = Duration(milliseconds: 500);
  static const Duration tapAnimationDuration = Duration(milliseconds: 100);
} 