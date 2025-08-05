import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 統計データ管理サービス
class StatsService {
  static final StatsService instance = StatsService._internal();
  StatsService._internal();

  static const String _dailyStatsKey = 'daily_stats';
  static const String _weeklyStatsKey = 'weekly_stats';

  /// 今日の日付を取得
  String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// 今日のタップ数を記録（実際のタップ数）
  Future<void> recordTodayTaps(int actualTaps) async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _getTodayKey();
    
    // 既存のデータを取得
    final dailyStatsJson = prefs.getString(_dailyStatsKey) ?? '{}';
    final dailyStats = Map<String, dynamic>.from(jsonDecode(dailyStatsJson));
    
    // 今日のタップ数を更新（実際のタップ数）
    final currentTaps = dailyStats[todayKey] ?? 0;
    final newTaps = currentTaps + actualTaps;
    dailyStats[todayKey] = newTaps;
    
    print('StatsService: 今日の統計タップ数を記録 - 現在=$currentTaps, 追加=$actualTaps, 新しい総数=$newTaps');
    
    // 保存
    await prefs.setString(_dailyStatsKey, jsonEncode(dailyStats));
    print('StatsService: 統計データ保存完了');
  }

  /// 今日の実際のタップ数を記録（倍率なし）
  Future<void> recordTodayActualTaps(int actualTaps) async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _getTodayKey() + '_actual';
    
    // 既存のデータを取得
    final dailyStatsJson = prefs.getString(_dailyStatsKey) ?? '{}';
    final dailyStats = Map<String, dynamic>.from(jsonDecode(dailyStatsJson));
    
    // 今日の実際のタップ数を更新（倍率なし）
    final currentTaps = dailyStats[todayKey] ?? 0;
    final newTaps = currentTaps + actualTaps;
    dailyStats[todayKey] = newTaps;
    
    print('StatsService: 今日の実際タップ数を記録 - 現在=$currentTaps, 追加=$actualTaps, 新しい総数=$newTaps');
    
    // 保存
    await prefs.setString(_dailyStatsKey, jsonEncode(dailyStats));
    print('StatsService: 実際タップ数統計保存完了');
  }

  /// 過去7日間の統計を取得（月曜日から始まる週）
  Future<List<DailyStats>> getLast7DaysStats() async {
    final prefs = await SharedPreferences.getInstance();
    final dailyStatsJson = prefs.getString(_dailyStatsKey) ?? '{}';
    final dailyStats = Map<String, dynamic>.from(jsonDecode(dailyStatsJson));
    
    final List<DailyStats> stats = [];
    final now = DateTime.now();
    
    // 今週の月曜日を計算
    final daysSinceMonday = now.weekday - 1; // 月曜日が0になるように調整
    final mondayOfThisWeek = now.subtract(Duration(days: daysSinceMonday));
    
    // 月曜日から日曜日までの7日間を取得
    for (int i = 0; i < 7; i++) {
      final date = mondayOfThisWeek.add(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final taps = dailyStats[dateKey] ?? 0;
      
      stats.add(DailyStats(
        date: date,
        taps: taps,
        dayName: _getDayName(date.weekday),
      ));
    }
    
    return stats;
  }

  /// 過去30日間の統計を取得
  Future<List<DailyStats>> getLast30DaysStats() async {
    final prefs = await SharedPreferences.getInstance();
    final dailyStatsJson = prefs.getString(_dailyStatsKey) ?? '{}';
    final dailyStats = Map<String, dynamic>.from(jsonDecode(dailyStatsJson));
    
    final List<DailyStats> stats = [];
    final now = DateTime.now();
    
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final taps = dailyStats[dateKey] ?? 0;
      
      stats.add(DailyStats(
        date: date,
        taps: taps,
        dayName: _getDayName(date.weekday),
      ));
    }
    
    return stats;
  }

  /// 今週の統計を取得（月曜日から始まる）
  Future<List<DailyStats>> getThisWeekStats() async {
    final prefs = await SharedPreferences.getInstance();
    final dailyStatsJson = prefs.getString(_dailyStatsKey) ?? '{}';
    final dailyStats = Map<String, dynamic>.from(jsonDecode(dailyStatsJson));
    
    final List<DailyStats> stats = [];
    final now = DateTime.now();
    
    // 今週の月曜日を計算
    final daysSinceMonday = now.weekday - 1; // 月曜日が0になるように調整
    final mondayOfThisWeek = now.subtract(Duration(days: daysSinceMonday));
    
    // 月曜日から日曜日までの7日間を取得
    for (int i = 0; i < 7; i++) {
      final date = mondayOfThisWeek.add(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final taps = dailyStats[dateKey] ?? 0;
      
      stats.add(DailyStats(
        date: date,
        taps: taps,
        dayName: _getDayName(date.weekday),
      ));
    }
    
    return stats;
  }

  /// 曜日名を取得
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return '月';
      case 2: return '火';
      case 3: return '水';
      case 4: return '木';
      case 5: return '金';
      case 6: return '土';
      case 7: return '日';
      default: return '';
    }
  }

  /// 今日のタップ数を取得
  Future<int> getTodayTaps() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _getTodayKey();
    final dailyStatsJson = prefs.getString(_dailyStatsKey) ?? '{}';
    final dailyStats = Map<String, dynamic>.from(jsonDecode(dailyStatsJson));
    
    return dailyStats[todayKey] ?? 0;
  }

  /// 今日の実際のタップ数を取得（倍率なし）
  Future<int> getTodayActualTaps() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _getTodayKey() + '_actual';
    final dailyStatsJson = prefs.getString(_dailyStatsKey) ?? '{}';
    final dailyStats = Map<String, dynamic>.from(jsonDecode(dailyStatsJson));
    
    return dailyStats[todayKey] ?? 0;
  }

  /// 今週のタップ数を取得
  Future<int> getWeeklyTaps() async {
    final weeklyStats = await getThisWeekStats();
    int total = 0;
    for (final stat in weeklyStats) {
      total += stat.taps;
    }
    return total;
  }

  /// 今月のタップ数を取得
  Future<int> getMonthlyTaps() async {
    final prefs = await SharedPreferences.getInstance();
    final dailyStatsJson = prefs.getString(_dailyStatsKey) ?? '{}';
    final dailyStats = Map<String, dynamic>.from(jsonDecode(dailyStatsJson));
    
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;
    
    int total = 0;
    
    // 今月のデータを集計
    for (final entry in dailyStats.entries) {
      final dateParts = entry.key.split('-');
      if (dateParts.length == 3) {
        final year = int.tryParse(dateParts[0]);
        final month = int.tryParse(dateParts[1]);
        
        if (year == currentYear && month == currentMonth) {
          total += entry.value as int;
        }
      }
    }
    
    return total;
  }

  /// 統計データをクリア
  Future<void> clearStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dailyStatsKey);
    await prefs.remove(_weeklyStatsKey);
  }
}

/// 日別統計データ
class DailyStats {
  final DateTime date;
  final int taps;
  final String dayName;

  DailyStats({
    required this.date,
    required this.taps,
    required this.dayName,
  });
} 