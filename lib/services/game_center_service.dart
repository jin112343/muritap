import 'dart:io';
import 'package:flutter/services.dart';

import '../config/app_config.dart';

/// ランキングエントリーデータクラス
class LeaderboardEntry {
  final String playerName;
  final int score;
  final int rank;
  final bool isCurrentPlayer;

  LeaderboardEntry({
    required this.playerName,
    required this.score,
    required this.rank,
    this.isCurrentPlayer = false,
  });

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntry(
      playerName: map['playerName'] ?? '',
      score: map['score'] ?? 0,
      rank: map['rank'] ?? 0,
      isCurrentPlayer: map['isCurrentPlayer'] ?? false,
    );
  }
}

/// GameCenter管理サービス
/// iOS限定の機能で、可用性を保つためエラーハンドリングを実装
class GameCenterService {
  static final GameCenterService _instance = GameCenterService._internal();
  factory GameCenterService() => _instance;
  GameCenterService._internal();

  static GameCenterService get instance => _instance;
  
  bool _isAvailable = false;
  bool _isSignedIn = false;
  
  // MethodChannel for GameCenter communication
  static const MethodChannel _channel = MethodChannel('game_center_channel');

  /// GameCenterが利用可能かチェック
  bool get isAvailable {
    if (!Platform.isIOS) return false;
    return _isAvailable;
  }

  /// GameCenterにサインイン済みかチェック
  bool get isSignedIn => _isSignedIn;

  /// GameCenterにサインイン
  Future<bool> signIn() async {
    if (!Platform.isIOS) return false;
    
    try {
      // GameCenterにサインインを試行
      final result = await _channel.invokeMethod('signInToGameCenter');
      _isSignedIn = result == true;
      _isAvailable = _isSignedIn;
      return _isSignedIn;
    } catch (e) {
      print('GameCenter sign in error: $e');
      _isSignedIn = false;
      _isAvailable = false;
      return false;
    }
  }

  /// タップ回数をスコアとして送信
  Future<bool> submitScore(int tapCount) async {
    if (!isAvailable || !_isSignedIn) {
      print('GameCenter is not available or not signed in');
      return false;
    }
    
    try {
      final result = await _channel.invokeMethod('submitScore', {
        'leaderboardId': AppConfig.leaderboardId,
        'score': tapCount,
      });
      return result == true;
    } catch (e) {
      print('Error submitting score to GameCenter: $e');
      return false;
    }
  }

  /// リーダーボードを表示
  Future<void> showLeaderboard() async {
    if (!isAvailable || !_isSignedIn) {
      print('GameCenter is not available or not signed in');
      return;
    }
    
    try {
      await _channel.invokeMethod('showLeaderboard', {
        'leaderboardId': AppConfig.leaderboardId,
      });
    } catch (e) {
      print('Error showing GameCenter leaderboard: $e');
    }
  }

  /// ランキングデータを取得
  Future<List<LeaderboardEntry>> getLeaderboardEntries() async {
    if (!isAvailable || !_isSignedIn) {
      print('GameCenter is not available or not signed in');
      return [];
    }
    
    try {
      final result = await _channel.invokeMethod('getLeaderboardEntries', {
        'leaderboardId': AppConfig.leaderboardId,
      });
      
      if (result is List) {
        return result.map((entry) => LeaderboardEntry.fromMap(Map<String, dynamic>.from(entry))).toList();
      }
      return [];
    } catch (e) {
      print('Error getting leaderboard entries: $e');
      return [];
    }
  }

  /// GameCenter設定画面を開く
  Future<void> openGameCenterSettings() async {
    if (!Platform.isIOS) return;
    
    try {
      await _channel.invokeMethod('openGameCenterSettings');
    } catch (e) {
      print('Error opening GameCenter settings: $e');
    }
  }

  /// 現在のプレイヤーのスコアを取得
  Future<int?> getCurrentPlayerScore() async {
    if (!isAvailable || !_isSignedIn) return null;
    
    try {
      final result = await _channel.invokeMethod('getCurrentPlayerScore', {
        'leaderboardId': AppConfig.leaderboardId,
      });
      return result as int?;
    } catch (e) {
      print('Error getting current player score: $e');
      return null;
    }
  }

  /// 利用可能なリーダーボードIDを取得
  String getLeaderboardId() {
    return AppConfig.leaderboardId;
  }

  /// GameCenterの状態をリセット（テスト用）
  void reset() {
    _isAvailable = false;
    _isSignedIn = false;
  }
} 