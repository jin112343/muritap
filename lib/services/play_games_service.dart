import 'dart:io';
import 'package:games_services/games_services.dart';
import 'package:logger/logger.dart';

import '../config/app_config.dart';

/// Play Gamesランキングエントリーデータクラス
class PlayGamesLeaderboardEntry {
  final String playerName;
  final int score;
  final int rank;
  final bool isCurrentPlayer;

  PlayGamesLeaderboardEntry({
    required this.playerName,
    required this.score,
    required this.rank,
    this.isCurrentPlayer = false,
  });
}

/// Google Play Games管理サービス
/// Android限定の機能で、可用性を保つためエラーハンドリングを実装
class PlayGamesService {
  static final PlayGamesService _instance = PlayGamesService._internal();
  factory PlayGamesService() => _instance;
  PlayGamesService._internal();

  static PlayGamesService get instance => _instance;

  final Logger _logger = Logger();
  bool _isSignedIn = false;

  /// Play Gamesが利用可能かチェック
  bool get isAvailable => Platform.isAndroid;

  /// Play Gamesにサインイン済みかチェック
  bool get isSignedIn => _isSignedIn;

  /// Play Gamesにサインイン
  Future<bool> signIn() async {
    if (!Platform.isAndroid) {
      _logger.w('signIn: Play Games is only available on Android');
      return false;
    }

    try {
      final result = await GamesServices.signIn();
      _isSignedIn = result != null && result.isNotEmpty;
      _logger.i('signIn: success=$_isSignedIn, result=$result');
      return _isSignedIn;
    } catch (e, stackTrace) {
      _logger.e(
        'signIn: error',
        error: e,
        stackTrace: stackTrace,
      );
      _isSignedIn = false;
      return false;
    }
  }

  /// タップ回数をスコアとして送信
  Future<bool> submitScore(int tapCount) async {
    if (!isAvailable || !_isSignedIn) {
      _logger.w(
        'submitScore: Play Games is not available or not signed in',
        error: 'tapCount=$tapCount',
      );
      return false;
    }

    try {
      await GamesServices.submitScore(
        score: Score(
          androidLeaderboardID: AppConfig.playGamesLeaderboardId,
          value: tapCount,
        ),
      );
      _logger.i('submitScore: success, tapCount=$tapCount');
      return true;
    } catch (e, stackTrace) {
      _logger.e(
        'submitScore: error',
        error: 'tapCount=$tapCount, exception=$e',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// リーダーボードを表示
  Future<void> showLeaderboard() async {
    if (!isAvailable || !_isSignedIn) {
      _logger.w('showLeaderboard: Play Games is not available or not signed in');
      return;
    }

    try {
      await GamesServices.showLeaderboards(
        androidLeaderboardID: AppConfig.playGamesLeaderboardId,
      );
      _logger.i('showLeaderboard: success');
    } catch (e, stackTrace) {
      _logger.e(
        'showLeaderboard: error',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// アチーブメントを表示
  Future<void> showAchievements() async {
    if (!isAvailable || !_isSignedIn) {
      _logger.w(
          'showAchievements: Play Games is not available or not signed in');
      return;
    }

    try {
      await GamesServices.showAchievements();
      _logger.i('showAchievements: success');
    } catch (e, stackTrace) {
      _logger.e(
        'showAchievements: error',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// アチーブメントをアンロック
  Future<bool> unlockAchievement(String achievementId) async {
    if (!isAvailable || !_isSignedIn) {
      _logger.w(
        'unlockAchievement: Play Games is not available or not signed in',
        error: 'achievementId=$achievementId',
      );
      return false;
    }

    try {
      await GamesServices.unlock(
        achievement: Achievement(
          androidID: achievementId,
        ),
      );
      _logger.i('unlockAchievement: success, achievementId=$achievementId');
      return true;
    } catch (e, stackTrace) {
      _logger.e(
        'unlockAchievement: error',
        error: 'achievementId=$achievementId, exception=$e',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Play Gamesの状態をリセット（テスト用）
  void reset() {
    _isSignedIn = false;
  }
}
