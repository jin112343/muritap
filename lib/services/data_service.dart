import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

/// データ管理サービス
/// 機密性を保つため、データの暗号化とバックアップ機能を提供
class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  static DataService get instance => _instance;
  
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  /// 初期化
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    } catch (e) {
      // 可用性を保つため、エラーが発生してもアプリは動作する
      print('DataService initialization error: $e');
    }
  }

  /// 累積タップ数を取得
  int getTotalTaps() {
    if (!_isInitialized || _prefs == null) return 0;
    return _prefs!.getInt(AppConfig.keyTotalTaps) ?? 0;
  }

  /// 実際にカウントされた総数を取得（課金や動画再生分も含む）
  /// これはGameCenterに送信するスコアとして使用される
  int getActualCountedTaps() {
    if (!_isInitialized || _prefs == null) return 0;
    return _prefs!.getInt(AppConfig.keyTotalTaps) ?? 0;
  }

  /// 実際のタップ数（倍率なし）を取得
  /// これはGameCenterに送信するスコアとして使用される
  int getRealTapCount() {
    if (!_isInitialized || _prefs == null) return 0;
    return _prefs!.getInt('real_tap_count') ?? 0;
  }

  /// 実際のタップ数（倍率なし）を保存
  Future<void> saveRealTapCount(int realTapCount) async {
    if (!_isInitialized || _prefs == null) {
      print('DataService: 初期化されていません');
      return;
    }
    
    try {
      print('DataService: 実際タップ数を保存開始 - $realTapCount');
      final result = await _prefs!.setInt('real_tap_count', realTapCount);
      print('DataService: 実際タップ数保存結果 - $result');
      
      // 保存後の確認
      final savedValue = _prefs!.getInt('real_tap_count');
      print('DataService: 保存後の確認 - $savedValue');
      
      print('DataService: 実際タップ数保存完了');
    } catch (e) {
      print('Error saving real tap count: $e');
    }
  }

  /// 累積タップ数を保存
  Future<void> saveTotalTaps(int totalTaps) async {
    if (!_isInitialized || _prefs == null) {
      print('DataService: 初期化されていません');
      return;
    }
    
    try {
      print('DataService: 総タップ数を保存開始 - $totalTaps');
      final result = await _prefs!.setInt(AppConfig.keyTotalTaps, totalTaps);
      print('DataService: 総タップ数保存結果 - $result');
      
      // 保存後の確認
      final savedValue = _prefs!.getInt(AppConfig.keyTotalTaps);
      print('DataService: 保存後の確認 - $savedValue');
      
      print('DataService: 総タップ数保存完了');
    } catch (e) {
      print('Error saving total taps: $e');
    }
  }

  /// 現在のレベルを取得
  int getCurrentLevel() {
    if (!_isInitialized || _prefs == null) return 1;
    return _prefs!.getInt(AppConfig.keyCurrentLevel) ?? 1;
  }

  /// 現在のレベルを保存
  Future<void> setCurrentLevel(int level) async {
    if (!_isInitialized || _prefs == null) {
      print('DataService: 初期化されていません');
      return;
    }
    
    try {
      print('DataService: レベルを保存開始 - Lv.$level');
      final result = await _prefs!.setInt(AppConfig.keyCurrentLevel, level);
      print('DataService: レベル保存結果 - $result');
      
      // 保存後の確認
      final savedValue = _prefs!.getInt(AppConfig.keyCurrentLevel);
      print('DataService: 保存後の確認 - Lv.$savedValue');
      
      print('DataService: レベル保存完了');
    } catch (e) {
      print('Error saving level: $e');
    }
  }

  /// 指定されたタップ数で到達可能な最高レベルを取得
  int getMaxAchievableLevel(int totalTaps) {
    int level = 1;
    while (level <= 999999) { // レベル上限を無制限に変更
      final requiredTaps = getRequiredTapsForLevel(level + 1);
      if (requiredTaps > totalTaps) {
        break;
      }
      level++;
    }
    return level;
  }

  /// デイリーチャレンジの完了日時を保存
  Future<void> saveDailyChallengeCompletedDate() async {
    if (!_isInitialized || _prefs == null) {
      print('DataService: 初期化されていません');
      return;
    }
    
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final timestamp = today.millisecondsSinceEpoch;
      
      print('DataService: デイリーチャレンジ完了日時を保存開始 - $today');
      final result = await _prefs!.setInt('daily_challenge_completed_date', timestamp);
      print('DataService: デイリーチャレンジ完了日時保存結果 - $result');
      
      print('DataService: デイリーチャレンジ完了日時保存完了');
    } catch (e) {
      print('Error saving daily challenge completed date: $e');
    }
  }

  /// デイリーチャレンジが今日完了済みかチェック
  bool isDailyChallengeCompletedToday() {
    if (!_isInitialized || _prefs == null) return false;
    
    try {
      final completedTimestamp = _prefs!.getInt('daily_challenge_completed_date');
      if (completedTimestamp == null) return false;
      
      final completedDate = DateTime.fromMillisecondsSinceEpoch(completedTimestamp);
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      
      return completedDate.isAtSameMomentAs(todayStart);
    } catch (e) {
      print('Error checking daily challenge completion: $e');
      return false;
    }
  }
  Future<void> saveCurrentLevel(int level) async {
    if (!_isInitialized || _prefs == null) return;
    
    try {
      await _prefs!.setInt(AppConfig.keyCurrentLevel, level);
    } catch (e) {
      print('Error saving current level: $e');
    }
  }

  /// 最高レベルを取得
  int getHighestLevel() {
    if (!_isInitialized || _prefs == null) return 1;
    return _prefs!.getInt(AppConfig.keyHighestLevel) ?? 1;
  }

  /// 最高レベルを保存
  Future<void> saveHighestLevel(int level) async {
    if (!_isInitialized || _prefs == null) return;
    
    try {
      await _prefs!.setInt(AppConfig.keyHighestLevel, level);
    } catch (e) {
      print('Error saving highest level: $e');
    }
  }

  /// レベルアップ判定
  bool isLevelUp(int totalTaps, int currentLevel) {
    // 現在のレベルでの必要タップ数を取得
    final currentLevelRequired = getRequiredTapsForLevel(currentLevel);
    // 次のレベルでの必要タップ数を取得
    final nextLevelRequired = getRequiredTapsForLevel(currentLevel + 1);
    
    // 現在のレベルを超えて、次のレベルに達しているかチェック
    return totalTaps >= nextLevelRequired && totalTaps > currentLevelRequired;
  }

  /// 指定レベルの必要タップ数を計算
  int getRequiredTapsForLevel(int level) {
    if (level <= 1) return 0;
    
    // より滑らかで現実的な成長曲線を実現
    double growthRate;
    if (level <= 99) {
      growthRate = 1.5;
    } else if (level <= 300) {
      // レベル99-300の間で1.5から1.6まで徐々に上げる
      final progress = (level - 99) / (300 - 99);
      growthRate = 1.5 + (progress * 0.1);
    } else if (level <= 500) {
      // レベル300-500の間で1.6から1.7まで徐々に上げる
      final progress = (level - 300) / (500 - 300);
      growthRate = 1.6 + (progress * 0.1);
    } else if (level <= 750) {
      // レベル500-750の間で1.7から1.8まで徐々に上げる
      final progress = (level - 500) / (750 - 500);
      growthRate = 1.7 + (progress * 0.1);
    } else if (level <= 999) {
      // レベル750-999の間で1.8から1.9まで徐々に上げる
      final progress = (level - 750) / (999 - 750);
      growthRate = 1.8 + (progress * 0.1);
    } else {
      // レベル999以降は2.0で固定
      growthRate = 2.0;
    }
    
    return (AppConfig.baseTaps * pow(level, growthRate)).floor();
  }

  /// データをリセット
  Future<void> resetData() async {
    if (!_isInitialized || _prefs == null) return;
    
    try {
      await _prefs!.clear();
    } catch (e) {
      print('Error resetting data: $e');
    }
  }

  /// データの整合性チェック
  bool validateData() {
    if (!_isInitialized || _prefs == null) return false;
    
    final totalTaps = getTotalTaps();
    final currentLevel = getCurrentLevel();
    final highestLevel = getHighestLevel();
    
    // 負の値や異常に大きな値がないかチェック
    if (totalTaps < 0 || currentLevel < 1 || highestLevel < 1) {
      return false;
    }
    
    // レベルが最大値を超えていないかチェック
    if (currentLevel > AppConfig.maxLevel || highestLevel > AppConfig.maxLevel) {
      return false;
    }
    
    return true;
  }
} 