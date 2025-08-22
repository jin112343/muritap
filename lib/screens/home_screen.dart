import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferencesを追加
import 'package:in_app_review/in_app_review.dart'; // App Store評価用

import '../config/app_config.dart';
import '../config/theme_config.dart';
import '../services/data_service.dart';
import '../services/ad_service.dart';
import '../services/purchase_service.dart';
import '../services/share_service.dart';
import '../services/game_center_service.dart';
import '../services/title_service.dart';
import '../services/stats_service.dart';
import '../widgets/tap_button.dart';
import '../l10n/app_localizations.dart';

/// ホーム画面
/// メインのタップ機能とレベル表示を提供
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // 状態変数
  int totalTaps = 0;
  int currentLevel = 1;
  bool isLevelUp = false;
  bool isProcessingTap = false;
  
  // アニメーションコントローラー
  late AnimationController tapAnimationController;
  late AnimationController levelUpAnimationController;
  late AnimationController levelUpNotificationController;
  
  // 動画再生の状態
  bool isRewardedAdLoaded = false;
  
  // バナー広告の読み込み状態
  bool isBannerAdLoaded = false;
  
  // 新しい機能の状態
  bool showTutorial = false;
  bool showDailyChallenge = false;
  bool showAchievements = false;
  
  // デイリーチャレンジの状態
  int dailyChallengeProgress = 0;
  int dailyChallengeTarget = 100;
  int dailyChallengeReward = 50;
  
  // アチーブメントの状態
  List<Map<String, dynamic>> achievements = [];
  
  // タイマー
  Timer? _dataTimer;
  Timer? _adTimer;
  Timer? _statsTimer;
  
  // スクリーンショット用のキー
  final GlobalKey screenshotKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    
    // アニメーションコントローラーを初期化
    tapAnimationController = AnimationController(
      duration: AppConfig.tapAnimationDuration,
      vsync: this,
    );
    levelUpAnimationController = AnimationController(
      duration: AppConfig.levelUpAnimationDuration,
      vsync: this,
    );
    levelUpNotificationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // 初期データを読み込み
    _loadInitialData();
    
    // 広告を読み込み
    _loadAds();
    
    // データの変更を監視
    _startDataMonitoring();
    
    // 広告の状態を定期的にチェック
    _startAdMonitoring();
  }

  @override
  void dispose() {
    _dataTimer?.cancel();
    _adTimer?.cancel();
    _statsTimer?.cancel();
    tapAnimationController.dispose();
    levelUpAnimationController.dispose();
    levelUpNotificationController.dispose();
    super.dispose();
  }

  // 初期データを読み込み
  void _loadInitialData() {
    totalTaps = DataService.instance.getTotalTaps();
    currentLevel = DataService.instance.getCurrentLevel();
    developer.log('初期データ読み込み完了: タップ数=$totalTaps, レベル=$currentLevel');
  }

  // 広告を読み込み
  void _loadAds() {
    AdService.instance.loadBannerAd();
    AdService.instance.loadRewardedAd();
  }

  // データの変更を監視
  void _startDataMonitoring() {
    _dataTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      final newTotalTaps = DataService.instance.getTotalTaps();
      final newCurrentLevel = DataService.instance.getCurrentLevel();
      
      if (newTotalTaps != totalTaps) {
        setState(() {
          totalTaps = newTotalTaps;
        });
      }
      
      if (newCurrentLevel != currentLevel) {
        setState(() {
          currentLevel = newCurrentLevel;
        });
      }
    });
  }

  // 広告の状態を定期的にチェック
  void _startAdMonitoring() {
    _adTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final currentBannerLoaded = AdService.instance.isBannerAdLoaded;
      final currentRewardedLoaded = AdService.instance.isRewardedAdLoaded;
      
      if (currentBannerLoaded != isBannerAdLoaded) {
        setState(() {
          isBannerAdLoaded = currentBannerLoaded;
        });
      }
      
      if (currentRewardedLoaded != isRewardedAdLoaded) {
        setState(() {
          isRewardedAdLoaded = currentRewardedLoaded;
        });
      }
    });
    
    // 動画広告の読み込み状態を監視
    _statsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentRewardedLoaded = AdService.instance.isRewardedAdLoaded;
      if (currentRewardedLoaded != isRewardedAdLoaded) {
        setState(() {
          isRewardedAdLoaded = currentRewardedLoaded;
        });
      }
    });
  }

  // プログレスバーの進捗率を計算（経験値方式）
  double _getProgressFactor(int currentLevel, int totalTaps) {
    // 現在のレベルでの必要タップ数
    final currentLevelRequired = DataService.instance.getRequiredTapsForLevel(currentLevel);
    // 次のレベルでの必要タップ数
    final nextLevelRequired = DataService.instance.getRequiredTapsForLevel(currentLevel + 1);
    
    // 現在のレベルでの進捗
    final progress = totalTaps - currentLevelRequired;
    // 次のレベルまでの必要タップ数
    final required = nextLevelRequired - currentLevelRequired;
    
    if (required <= 0) return 1.0;
    if (progress <= 0) return 0.0;
    if (progress >= required) return 1.0;
    
    // 経験値バーのように左から右に進む
    return progress / required;
  }

  // タップ数をそのまま表示（表記変換なし）
  String _formatTapCount(int totalTaps, BuildContext context) {
    // 最高上限: 999,999,999,999,999,999
    const int maxValue = 999999999999999999;
    
    if (totalTaps > maxValue) {
      totalTaps = maxValue;
    }
    
    // 数字をそのまま返す
    return totalTaps.toString();
  }

  // レベル99からレベル100になった時に評価ダイアログを表示
  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 28),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.homeRatingDialogTitle),
            ],
          ),
          content: Text(
            AppLocalizations.of(context)!.homeRatingDialogContent,
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.homeRatingDialogLater),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                // App Store評価をリクエスト
                _requestAppStoreReview();
              },
              icon: const Icon(Icons.star_rate),
              label: Text(AppLocalizations.of(context)!.homeRatingDialogRateOnAppStore),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  // App Store評価をリクエスト
  Future<void> _requestAppStoreReview() async {
    try {
      final InAppReview inAppReview = InAppReview.instance;
      
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
        developer.log('App Store評価ダイアログを表示しました');
        // 評価完了後に評価済みフラグを設定
        await _markAsRated();
      } else {
        developer.log('App Store評価が利用できません');
        // 代替手段として、App Storeページを開く
        await inAppReview.openStoreListing();
        // App Storeページを開いた場合も評価済みとしてマーク
        await _markAsRated();
      }
    } catch (e) {
      developer.log('App Store評価のリクエストに失敗しました: $e');
    }
  }

  // 評価済みとしてマーク
  Future<void> _markAsRated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_rated', true);
      await prefs.setString('rating_date', DateTime.now().toIso8601String());
      developer.log('評価済みとしてマークしました');
    } catch (e) {
      developer.log('評価済みフラグの設定に失敗しました: $e');
    }
  }

  // 評価済みかどうかをチェック
  Future<bool> _hasUserRated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('has_rated') ?? false;
    } catch (e) {
      developer.log('評価状態の確認に失敗しました: $e');
      return false;
    }
  }

  // 評価ダイアログを表示するかチェック
  Future<bool> _shouldShowRatingDialog() async {
    // 既に評価済みの場合は表示しない
    if (await _hasUserRated()) {
      return false;
    }
    return true;
  }

  // 評価ダイアログを表示
  Future<void> _showRatingDialogIfNeeded(BuildContext context) async {
    if (await _shouldShowRatingDialog()) {
      _showRatingDialog(context);
    }
  }

  // 現在のトータルタップ数で行ける最高レベルにスキップする
  void _skipToCurrentLevel(
    BuildContext context, 
    int currentTotalTaps, 
    int totalTaps,
    int currentLevel,
    bool isLevelUp,
    AnimationController levelUpAnimationController,
  ) async {
    try {
      developer.log('=== スキップ処理開始 ===');
      developer.log('現在のタップ数: $currentTotalTaps');
      
      // 現在のタップ数で行ける最高レベルを計算
      int maxLevel = 1;
      for (int level = 1; level <= 999; level++) {
        final requiredTaps = DataService.instance.getRequiredTapsForLevel(level);
        if (currentTotalTaps >= requiredTaps) {
          maxLevel = level;
        } else {
          break;
        }
      }
      
      developer.log('現在のタップ数で行ける最高レベル: Lv.$maxLevel');
      
              // 現在のタップ数で到達可能な最高レベルを計算
        final maxAchievableLevel = DataService.instance.getMaxAchievableLevel(currentTotalTaps);
        
        developer.log('現在のタップ数で到達可能な最高レベル: Lv.$maxAchievableLevel');
        
        // 現在のレベルが到達可能な最高レベルより低い場合
        if (currentLevel < maxAchievableLevel) {
        // 確認ダイアログを表示
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.dialogsLevelSkipTitle),
            content: Text(
              '現在のタップ数で行ける最高レベル（Lv.$maxAchievableLevel）までスキップしますか？\n\n'
              '現在のタップ数: ${_formatTapCount(currentTotalTaps, context)}\n'
              '到達可能な最高レベル: Lv.$maxAchievableLevel\n\n'
              'スキップ後は、現在のタップ数はそのままで、レベルだけが最高レベルに設定されます。',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppLocalizations.of(context)!.dialogsLevelSkipCancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConfig.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(AppLocalizations.of(context)!.dialogsLevelSkipSkip),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          developer.log('スキップが承認されました');
          
          // スキップ処理を実行（タップ数は変更せず、レベルだけを更新）
          // 現在のタップ数で到達可能な最高レベルを計算
          final maxAchievableLevel = DataService.instance.getMaxAchievableLevel(currentTotalTaps);
          developer.log('現在のタップ数で到達可能な最高レベル: Lv.$maxAchievableLevel');
          
          // レベルを更新（タップ数は変更しない）
          await DataService.instance.setCurrentLevel(maxAchievableLevel);
          developer.log('レベルを設定: Lv.$maxAchievableLevel');
          
          // 少し待ってからレベルを再取得
          await Future.delayed(const Duration(milliseconds: 100));
          
          // 現在のレベルを取得
          final newLevel = DataService.instance.getCurrentLevel();
          developer.log('新しいレベル: Lv.$newLevel');
          
          // 強制的にUIを再構築するために、状態変数を更新
          // タップ数は変更せず、レベルとレベルアップ状態のみ更新
          setState(() {
            currentLevel = newLevel;
            isLevelUp = true;
          });
          
          developer.log('UIの強制再構築を実行: タップ数=$totalTaps（変更なし）, レベル=$currentLevel, レベルアップ=$isLevelUp');
          
          // さらに確実にするために、もう一度少し待つ
          await Future.delayed(const Duration(milliseconds: 50));
          
          // 確実にUIが更新されるように、状態変数を再度設定
          if (context.mounted) {
            // 強制的に再構築を促す
            setState(() {
              currentLevel = currentLevel;
              isLevelUp = isLevelUp;
            });
            developer.log('状態変数の強制更新完了');
          }
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.homeSkipSuccess(maxAchievableLevel.toString())),
                backgroundColor: Colors.green,
              ),
            );
            
            // レベルアップアニメーションを実行
            try {
              levelUpAnimationController.forward();
              developer.log('レベルアップアニメーション開始');
            } catch (e) {
              developer.log('レベルアップアニメーションエラー: $e');
            }
          }
          
          developer.log('=== スキップ処理完了 ===');
        } else {
          developer.log('スキップがキャンセルされました');
        }
      } else {
        // 既に最高レベルに到達している場合
        developer.log('既に最高レベルに到達しています');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.homeAlreadyMaxLevel),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      developer.log('スキップ処理でエラーが発生: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.homeSkipError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // クラス変数を使用（フックは削除済み）



    // アチーブメントを更新する関数
    List<Map<String, dynamic>> updateAchievements() {
      final newAchievements = <Map<String, dynamic>>[];
      
      // レベルアチーブメント
      if (currentLevel >= 10) {
        newAchievements.add({
          'title': AppLocalizations.of(context)!.achievementLevel10Title,
          'description': AppLocalizations.of(context)!.achievementLevel10Description,
          'icon': Icons.star,
          'color': Colors.amber,
          'completed': true,
        });
      }
      
      if (currentLevel >= 50) {
        newAchievements.add({
          'title': AppLocalizations.of(context)!.achievementLevel50Title,
          'description': AppLocalizations.of(context)!.achievementLevel50Description,
          'icon': Icons.star,
          'color': Colors.orange,
          'completed': true,
        });
      }
      
      if (currentLevel >= 100) {
        newAchievements.add({
          'title': AppLocalizations.of(context)!.achievementLevel100Title,
          'description': AppLocalizations.of(context)!.achievementLevel100Description,
          'icon': Icons.star,
          'color': Colors.red,
          'completed': true,
        });
      }
      
      // タップ数アチーブメント
      if (totalTaps >= 1000) {
        newAchievements.add({
          'title': AppLocalizations.of(context)!.achievement1000TapsTitle,
          'description': AppLocalizations.of(context)!.achievement1000TapsDescription,
          'icon': Icons.touch_app,
          'color': Colors.blue,
          'completed': true,
        });
      }
      
      if (totalTaps >= 10000) {
        newAchievements.add({
          'title': AppLocalizations.of(context)!.achievement10000TapsTitle,
          'description': AppLocalizations.of(context)!.achievement10000TapsDescription,
          'icon': Icons.touch_app,
          'color': Colors.green,
          'completed': true,
        });
      }
      
      return newAchievements;
    }



    // アチーブメントを更新
    achievements = updateAchievements();

    // デイリーチャレンジを開始
    void startDailyChallenge() {
      // 今日既に完了済みの場合は開始できない
      if (DataService.instance.isDailyChallengeCompletedToday()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.dailyChallengeAlreadyCompleted),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      setState(() {
        showDailyChallenge = true;
        dailyChallengeProgress = 0;
        dailyChallengeTarget = 100 + (currentLevel * 10);
        dailyChallengeReward = 50 + (currentLevel * 5);
      });
    }

    // デイリーチャレンジを完了
    void completeDailyChallenge() async {
      if (dailyChallengeProgress >= dailyChallengeTarget) {
        // 報酬を付与
        final reward = dailyChallengeReward;
        final newTotalTaps = totalTaps + reward;
        setState(() {
          totalTaps = newTotalTaps;
          showDailyChallenge = false;
        });
        await DataService.instance.saveTotalTaps(newTotalTaps);
        
        // デイリーチャレンジ完了日時を保存
        await DataService.instance.saveDailyChallengeCompletedDate();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.dailyChallengeCompleted(reward.toString())),
            backgroundColor: Colors.green,
          ),
        );
      }
    }

    // 動画再生ボタンの処理（ポップアップ表示）
    void onWatchAd() async {
      if (isRewardedAdLoaded) {
        // 確認ダイアログを表示
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.videoAdTitle),
            content: Text(AppLocalizations.of(context)!.videoAdDescription),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(AppLocalizations.of(context)!.watchVideo),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          developer.log('=== 動画再生開始 ===');
          developer.log('現在の総タップ数: $totalTaps');
          developer.log('現在の実際タップ数: ${DataService.instance.getRealTapCount()}');
          developer.log('現在の統計タップ数: ${await StatsService.instance.getTodayTaps()}');
          developer.log('現在の実際統計タップ数: ${await StatsService.instance.getTodayActualTaps()}');
          
          try {
            final success = await AdService.instance.showRewardedAd();
            developer.log('動画再生結果: $success');
            
            if (success) {
              developer.log('=== 動画報酬処理開始 ===');
              // 動画視聴完了時の報酬（250タップ追加）
              final rewardTaps = 250;
              final tapMultiplier = await PurchaseService.instance.getTapMultiplier();
              final actualReward = rewardTaps * tapMultiplier;
              
              developer.log('動画報酬計算: 基本報酬=$rewardTaps, 倍率=$tapMultiplier, 実際報酬=$actualReward');
              
              final currentTotalTaps = DataService.instance.getTotalTaps();
              final newTotalTaps = currentTotalTaps + actualReward;
              developer.log('タップ数更新: 現在=$currentTotalTaps, 追加=$actualReward, 新しい総数=$newTotalTaps');
              
              // データを順次保存
              await DataService.instance.saveTotalTaps(newTotalTaps);
              developer.log('総タップ数保存完了');
              
              // 保存後の確認
              final savedTotalTaps = DataService.instance.getTotalTaps();
              developer.log('保存後の総タップ数確認: $savedTotalTaps');
              
              // 統計データを記録（実際のタップ数）
              await StatsService.instance.recordTodayTaps(actualReward);
              developer.log('統計タップ数記録完了');
              
              // 実際のタップ数も記録（倍率なし）
              await StatsService.instance.recordTodayActualTaps(250);
              developer.log('実際タップ数統計記録完了');
              
              // 実際のタップ数（倍率なし）を記録
              final currentRealTaps = DataService.instance.getRealTapCount();
              final newRealTaps = currentRealTaps + 250;
              await DataService.instance.saveRealTapCount(newRealTaps);
              developer.log('実際タップ数保存完了');
              
              // 保存後の確認
              final savedRealTaps = DataService.instance.getRealTapCount();
              developer.log('保存後の実際タップ数確認: $savedRealTaps');
              
              // 少し待ってからUIを更新（保存の反映を待つ）
              await Future.delayed(const Duration(milliseconds: 100));
              
              // UIを更新
                      setState(() {
          totalTaps = DataService.instance.getTotalTaps();
        });
        developer.log('UI更新後の総タップ数: $totalTaps');

              // リワード広告を再読み込み
              await AdService.instance.loadRewardedAd();
              
              // リアルタイム更新を強制実行
                      setState(() {
          totalTaps = DataService.instance.getTotalTaps();
        });
        developer.log('強制更新後の総タップ数: $totalTaps');
              
              developer.log('=== 動画報酬処理完了 ===');
              developer.log('最終確認 - 総タップ数: ${DataService.instance.getTotalTaps()}, 実際タップ数: ${DataService.instance.getRealTapCount()}');

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.homeVideoAdSuccess),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } else {
              developer.log('動画再生失敗 - 報酬が獲得されませんでした');
              // 動画視聴に失敗した場合
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.videoAdFailed),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              // リワード広告を再読み込み
              await AdService.instance.loadRewardedAd();
            }
          } catch (e) {
            developer.log('動画再生処理でエラーが発生: $e');
            // エラーが発生した場合でも、報酬を付与
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.videoAdCompletedWithError),
                  backgroundColor: Colors.orange,
                ),
              );
            }
            // リワード広告を再読み込み
            await AdService.instance.loadRewardedAd();
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.homeVideoAdLoading),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }

    // 共有ボタンの処理
    void onShare() async {
      // スクリーンショット時に広告を非表示にする
      AdService.instance.hideAd();
      
      // 少し待ってからスクリーンショットを撮影（UI更新のため）
      await Future.delayed(const Duration(milliseconds: 100));
      
      try {
        await ShareService.instance.shareScreenshot(
          screenshotKey,
          text: AppLocalizations.of(context)!.homeShareText(currentLevel.toString(), totalTaps.toString()),
        );
      } finally {
        // 共有完了後、広告を再表示
        AdService.instance.showAd();
      }
    }

    // タップ処理
    void onTap() async {
      // 既に処理中の場合は無視
      if (isProcessingTap) {
        return;
      }
      
      // 処理中フラグを設定
      setState(() {
        isProcessingTap = true;
      });
      
      try {
        // SharedPreferencesを取得
        final prefs = await SharedPreferences.getInstance();
        
        // タップアニメーション
        tapAnimationController.forward().then((_) {
          tapAnimationController.reverse();
        });

        // 課金倍率を取得
        final tapMultiplier = await PurchaseService.instance.getTapMultiplier();
        
        // タップ数を増加（倍率を適用）
        final tapIncrement = 1 * tapMultiplier;
        final newTotalTaps = totalTaps + tapIncrement;
        setState(() {
          totalTaps = newTotalTaps;
        });

        // データを保存
        await DataService.instance.saveTotalTaps(newTotalTaps);
        
        // 統計データを記録（実際のタップ数）
        await StatsService.instance.recordTodayTaps(tapIncrement);
        // 実際のタップ数も記録（倍率なし）
        await StatsService.instance.recordTodayActualTaps(1);
        
        // 実際のタップ数（倍率なし）を記録
        final currentRealTaps = DataService.instance.getRealTapCount();
        await DataService.instance.saveRealTapCount(currentRealTaps + 1);

        // デイリーチャレンジの進捗を更新
        if (showDailyChallenge) {
          setState(() {
            dailyChallengeProgress += tapIncrement;
          });
          if (dailyChallengeProgress >= dailyChallengeTarget) {
            completeDailyChallenge();
          }
        }

        // レベルアップ判定（現在のレベルで判定）
        final currentLevelForCheck = DataService.instance.getCurrentLevel();
        if (DataService.instance.isLevelUp(newTotalTaps, currentLevelForCheck)) {
          final newLevel = currentLevelForCheck + 1;
          setState(() {
            currentLevel = newLevel;
          });
          
          // レベルアップデータを保存
          await DataService.instance.saveCurrentLevel(newLevel);
          if (newLevel > DataService.instance.getHighestLevel()) {
            await DataService.instance.saveHighestLevel(newLevel);
          }

          // レベルアップ演出
          setState(() {
            isLevelUp = true;
          });
          levelUpAnimationController.forward().then((_) {
            levelUpAnimationController.reverse();
            setState(() {
              isLevelUp = false;
            });
          });
          
          // レベルアップ通知（レベルアップ時のみ）
          if (context.mounted) {
            // 既存のアニメーションをリセット
            levelUpNotificationController.reset();
            // 新しいアニメーションを開始
            levelUpNotificationController.forward();
            // 2秒後にスライドアウト
            Future.delayed(const Duration(seconds: 2), () {
              if (levelUpNotificationController.status == AnimationStatus.completed) {
                levelUpNotificationController.reverse();
              }
            });
          }

          // GameCenterにスコアを送信（レベルアップ時）- 累計数（倍率適用後）を使用
          if (GameCenterService.instance.isAvailable) {
            try {
              final totalTapsForGameCenter = DataService.instance.getTotalTaps(); // 累計数（倍率適用後）
              final success = await GameCenterService.instance.submitScore(totalTapsForGameCenter);
              if (success) {
                developer.log('GameCenter: Score submitted successfully: $totalTapsForGameCenter (total taps with multiplier)');
              } else {
                developer.log('GameCenter: Failed to submit score: $totalTapsForGameCenter');
              }
            } catch (e) {
              developer.log('GameCenter: Error submitting score: $e');
            }
          }

          // レベル99からレベル100になった時に評価ダイアログを表示
          if (newLevel == 100 && currentLevelForCheck == 99) {
            // 少し待ってから評価ダイアログを表示（レベルアップ演出の後に表示）
            Future.delayed(const Duration(seconds: 3), () {
              if (context.mounted) {
                _showRatingDialogIfNeeded(context);
              }
            });
          }
        } else {
          // レベルアップしていない場合も、一定間隔でスコアを送信
          if (newTotalTaps % 100 == 0) { // 100タップごとに送信
            if (GameCenterService.instance.isAvailable) {
              try {
                final totalTapsForGameCenter = DataService.instance.getTotalTaps(); // 累計数（倍率適用後）
                final success = await GameCenterService.instance.submitScore(totalTapsForGameCenter);
                if (success) {
                  developer.log('GameCenter: Score submitted periodically: $totalTapsForGameCenter (total taps with multiplier)');
                } else {
                  developer.log('GameCenter: Failed to submit score periodically: $totalTapsForGameCenter');
                }
              } catch (e) {
                developer.log('GameCenter: Error submitting score periodically: $e');
              }
            }
          }

          // 実質タップ数100回目のみ評価ダイアログを表示（評価済みでない場合のみ）
          final currentRealTaps = DataService.instance.getRealTapCount();
          if (currentRealTaps == 100) {
            // 既に100回目で表示済みかチェック
            final hasShownRatingAt100 = prefs.getBool('has_shown_rating_at_100') ?? false;
            if (!hasShownRatingAt100) {
              Future.delayed(const Duration(seconds: 1), () {
                if (context.mounted) {
                  _showRatingDialogIfNeeded(context);
                  // 100回目で表示済みフラグを設定
                  _markRatingDialogShownAt100();
                }
              });
            }
          }
        }
      } catch (e) {
        developer.log('Error in tap processing: $e');
      } finally {
        // 処理完了後、少し待ってからフラグをリセット（デバウンス）
        Future.delayed(const Duration(milliseconds: 50), () {
          setState(() {
          isProcessingTap = false;
        });
        });
      }
    }

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.appTitle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ThemeConfig.primaryColor,
                fontSize: 24,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            actions: [
              // 新機能ボタン
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: ThemeConfig.primaryColor),
                onSelected: (value) {
                  switch (value) {
                    case 'tutorial':
                      setState(() {
          showTutorial = true;
        });
                      break;
                                          case 'challenge':
                        startDailyChallenge();
                        break;
                    case 'achievements':
                      setState(() {
          showAchievements = true;
        });
                      break;

                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'tutorial',
                    child: Row(
                      children: [
                        const Icon(Icons.help_outline),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.tutorialTitle),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'challenge',
                    child: Row(
                      children: [
                        Icon(
                          DataService.instance.isDailyChallengeCompletedToday() 
                            ? Icons.check_circle 
                            : Icons.emoji_events,
                          color: DataService.instance.isDailyChallengeCompletedToday() 
                            ? Colors.green 
                            : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DataService.instance.isDailyChallengeCompletedToday() 
                            ? AppLocalizations.of(context)!.dailyChallengeCompletedShort
                            : AppLocalizations.of(context)!.dailyChallengeTitle,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'achievements',
                    child: Row(
                      children: [
                        const Icon(Icons.workspace_premium),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.achievementTitle),
                      ],
                    ),
                  ),

                ],
              ),
              // 動画再生ボタン
              IconButton(
                onPressed: onWatchAd,
                icon: Icon(
                  Icons.play_circle_outline,
                  color: isRewardedAdLoaded 
                    ? ThemeConfig.primaryColor 
                    : Colors.grey,
                ),
                tooltip: AppLocalizations.of(context)!.watchVideoTooltip,
              ),
              // 共有ボタン
              IconButton(
                onPressed: onShare,
                icon: const Icon(
                  Icons.share,
                  color: ThemeConfig.primaryColor,
                ),
                tooltip: 'スクリーンショットを共有',
              ),
            ],
          ),
          body: RepaintBoundary(
            key: screenshotKey,
            child: Container(
              color: ThemeConfig.backgroundColor, // 背景色を設定
              child: Column(
                children: [
                  // レベル表示（上部）
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ThemeConfig.surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: ThemeConfig.primaryColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        // レベルと称号
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.flash_on,
                              color: ThemeConfig.primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Lv.$currentLevel',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: ThemeConfig.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        
                        // 称号表示
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: TitleService.instance.getTitleColor(currentLevel).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: TitleService.instance.getTitleColor(currentLevel),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                TitleService.instance.getTitleIcon(currentLevel),
                                color: TitleService.instance.getTitleColor(currentLevel),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                                                              Text(
                                  TitleService.instance.getTitle(currentLevel, context),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: TitleService.instance.getTitleColor(currentLevel),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // タップ数表示（上部）
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      children: [
                                                  Text(
                            AppLocalizations.of(context)!.homeTotalTapsLabel,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[400],
                              letterSpacing: 1.2,
                            ),
                          ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _formatTapCount(totalTaps, context),
                            style: TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // 現在のタップ倍率を表示
                        FutureBuilder<int>(
                          future: PurchaseService.instance.getTapMultiplier(),
                          builder: (context, snapshot) {
                            final multiplier = snapshot.data ?? 1;
                            if (multiplier > 1) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.orange,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.flash_on,
                                      color: Colors.orange,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${multiplier}x TAP',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // プログレスバー（上部）
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    margin: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.homeNextLevelLabel,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[400],
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              'Lv.${currentLevel + 1}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: ThemeConfig.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: _getProgressFactor(currentLevel, totalTaps),
                          backgroundColor: Colors.grey[800],
                          valueColor: AlwaysStoppedAnimation<Color>(ThemeConfig.primaryColor),
                          minHeight: 6,
                        ),
                        const SizedBox(height: 4),
                        // 次のレベルまでの残りタップ数
                        Builder(
                          builder: (context) {
                                    final nextLevelRequired = DataService.instance.getRequiredTapsForLevel(currentLevel + 1);
        final remainingTaps = nextLevelRequired - totalTaps;
                            
                            // 既に次のレベルに達している場合
                            if (remainingTaps <= 0) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.homeNextLevelReached,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: ThemeConfig.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => _skipToCurrentLevel(context, totalTaps, totalTaps, currentLevel, isLevelUp, levelUpAnimationController),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: ThemeConfig.primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      minimumSize: const Size(0, 32),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.homeSkipButton,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                            
                            return Text(
                              AppLocalizations.of(context)!.homeRemainingTapsToLevel(remainingTaps.toString()),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[400],
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // デイリーチャレンジ表示
                  if (showDailyChallenge)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.dailyChallengeTitle,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                              Text(
                                AppLocalizations.of(context)!.dailyChallengeReward(dailyChallengeReward.toString()),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: dailyChallengeProgress / dailyChallengeTarget,
                            backgroundColor: Colors.grey[800],
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                            minHeight: 6,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$dailyChallengeProgress/$dailyChallengeTarget',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // スペーサー（レスポンシブ対応）
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Center(
                        child: TapButton(
                          onTap: onTap,
                          animationController: tapAnimationController,
                          isProcessing: isProcessingTap,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 広告表示（画面下部）
          bottomNavigationBar: AdService.instance.getBannerAdWidget() ?? const SizedBox.shrink(),
        ),
        
        // レベルアップ通知オーバーレイ（画面最上部）
        AnimatedBuilder(
          animation: levelUpNotificationController,
          builder: (context, child) {
            if (levelUpNotificationController.value <= 0) {
              return const SizedBox.shrink();
            }
            
            return Positioned(
              top: MediaQuery.of(context).padding.top + 80, // AppBarの下に表示
              left: 16,
              right: 16,
              child: Transform.translate(
                offset: Offset(0, -50 + (50 * levelUpNotificationController.value)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        ThemeConfig.primaryColor,
                        ThemeConfig.accentColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: ThemeConfig.primaryColor.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        AppLocalizations.of(context)!.homeLevelUpNotification(currentLevel.toString()),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        
        // チュートリアルダイアログ
        if (showTutorial)
          _buildTutorialDialog(context, () {
            setState(() {
              showTutorial = false;
            });
          }),
        
        // アチーブメントダイアログ
        if (showAchievements)
          _buildAchievementsDialog(context, () {
            setState(() {
              showAchievements = false;
            });
          }),
        

      ],
    );
  }

  // チュートリアルダイアログ
  Widget _buildTutorialDialog(BuildContext context, VoidCallback onClose) {
    return Dialog(
      backgroundColor: ThemeConfig.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.tutorialTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ThemeConfig.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            _buildTutorialStep(
              icon: Icons.touch_app,
              title: AppLocalizations.of(context)!.tutorialTapToLevelUp,
              description: AppLocalizations.of(context)!.tutorialTapToLevelUpDescription,
            ),
            const SizedBox(height: 16),
            _buildTutorialStep(
              icon: Icons.play_circle_outline,
              title: AppLocalizations.of(context)!.tutorialWatchVideoForReward,
              description: AppLocalizations.of(context)!.tutorialWatchVideoForRewardDescription,
            ),
            const SizedBox(height: 16),
            _buildTutorialStep(
              icon: Icons.emoji_events,
              title: AppLocalizations.of(context)!.tutorialDailyChallengeTitle,
              description: AppLocalizations.of(context)!.tutorialDailyChallengeDescription,
            ),
            const SizedBox(height: 16),
            _buildTutorialStep(
              icon: Icons.workspace_premium,
              title: AppLocalizations.of(context)!.tutorialAchievementTitle,
              description: AppLocalizations.of(context)!.tutorialAchievementDescription,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(AppLocalizations.of(context)!.understood),
            ),
          ],
        ),
      ),
    );
  }

  // チュートリアルステップ
  Widget _buildTutorialStep({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: ThemeConfig.primaryColor,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // アチーブメントダイアログ
  Widget _buildAchievementsDialog(BuildContext context, VoidCallback onClose) {
    return Dialog(
      backgroundColor: ThemeConfig.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.achievementTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ThemeConfig.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _getAchievements(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final achievements = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: achievements.length,
                    itemBuilder: (context, index) {
                      final achievement = achievements[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: achievement['color'].withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: achievement['color'].withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              achievement['icon'],
                              color: achievement['color'],
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    achievement['title'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: achievement['color'],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    achievement['description'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (achievement['completed'])
                              Icon(
                                Icons.check_circle,
                                color: achievement['color'],
                                size: 24,
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(AppLocalizations.of(context)!.close),
            ),
          ],
        ),
      ),
    );
  }

  // アチーブメントを取得
  Future<List<Map<String, dynamic>>> _getAchievements(BuildContext context) async {
    final currentLevel = DataService.instance.getCurrentLevel();
    final totalTaps = DataService.instance.getTotalTaps();
    final newAchievements = <Map<String, dynamic>>[];
    
    // レベルアチーブメント
    if (currentLevel >= 10) {
      newAchievements.add({
        'title': AppLocalizations.of(context)!.homeAchievementLevel10Title,
        'description': AppLocalizations.of(context)!.homeAchievementLevel10Description,
        'icon': Icons.star,
        'color': Colors.amber,
        'completed': true,
      });
    }
    
    if (currentLevel >= 50) {
      newAchievements.add({
        'title': AppLocalizations.of(context)!.homeAchievementLevel50Title,
        'description': AppLocalizations.of(context)!.homeAchievementLevel50Description,
        'icon': Icons.star,
        'color': Colors.orange,
        'completed': true,
      });
    }
    
    if (currentLevel >= 100) {
      newAchievements.add({
        'title': AppLocalizations.of(context)!.homeAchievementLevel100Title,
        'description': AppLocalizations.of(context)!.homeAchievementLevel100Description,
        'icon': Icons.star,
        'color': Colors.red,
        'completed': true,
      });
    }
    
    // タップ数アチーブメント
    if (totalTaps >= 1000) {
      newAchievements.add({
        'title': AppLocalizations.of(context)!.homeAchievement1000TapsTitle,
        'description': AppLocalizations.of(context)!.homeAchievement1000TapsDescription,
        'icon': Icons.touch_app,
        'color': Colors.blue,
        'completed': true,
      });
    }
    
    if (totalTaps >= 10000) {
      newAchievements.add({
        'title': AppLocalizations.of(context)!.homeAchievement10000TapsTitle,
        'description': AppLocalizations.of(context)!.homeAchievement10000TapsDescription,
        'icon': Icons.touch_app,
        'color': Colors.green,
        'completed': true,
      });
    }
    
    return newAchievements;
  }

  // 評価ダイアログを表示済みの実質タップ数を記録
  Future<void> _markRatingDialogShown(int currentRealTaps) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_shown_rating_tap', currentRealTaps);
    developer.log('評価ダイアログを表示済みの実質タップ数を記録: $currentRealTaps');
  }

  // 評価ダイアログを表示済みの実質タップ数を記録（100回目）
  Future<void> _markRatingDialogShownAt100() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_shown_rating_at_100', true);
    developer.log('評価ダイアログを100回目で表示済みとしてマークしました');
  }
} 