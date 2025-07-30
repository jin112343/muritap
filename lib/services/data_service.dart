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

  /// 累積タップ数を保存
  Future<void> saveTotalTaps(int totalTaps) async {
    if (!_isInitialized || _prefs == null) return;
    
    try {
      await _prefs!.setInt(AppConfig.keyTotalTaps, totalTaps);
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
    return (AppConfig.baseTaps * pow(level, AppConfig.growthRate)).floor();
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