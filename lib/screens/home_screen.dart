import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:async';
import 'dart:developer' as developer;

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

/// ホーム画面
/// メインのタップ機能とレベル表示を提供
class HomeScreen extends HookWidget {
  const HomeScreen({super.key});

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

  // 現在のトータルタップ数で行ける最高レベルにスキップする
  void _skipToCurrentLevel(
    BuildContext context, 
    int currentTotalTaps, 
    ValueNotifier<int> totalTapsNotifier,
    ValueNotifier<int> currentLevelNotifier,
    ValueNotifier<bool> isLevelUpNotifier,
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
        if (currentLevelNotifier.value < maxAchievableLevel) {
        // 確認ダイアログを表示
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('レベルスキップ'),
            content: Text(
              '現在のタップ数で行ける最高レベル（Lv.$maxAchievableLevel）までスキップしますか？\n\n'
              '現在のタップ数: ${_formatTapCount(currentTotalTaps, context)}\n'
              '到達可能な最高レベル: Lv.$maxAchievableLevel\n\n'
              'スキップ後は、現在のタップ数はそのままで、レベルだけが最高レベルに設定されます。',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('キャンセル'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConfig.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('スキップ'),
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
          currentLevelNotifier.value = newLevel;
          isLevelUpNotifier.value = true;
          
          developer.log('UIの強制再構築を実行: タップ数=${totalTapsNotifier.value}（変更なし）, レベル=${currentLevelNotifier.value}, レベルアップ=${isLevelUpNotifier.value}');
          
          // さらに確実にするために、もう一度少し待つ
          await Future.delayed(const Duration(milliseconds: 50));
          
          // 確実にUIが更新されるように、状態変数を再度設定
          if (context.mounted) {
            // 強制的に再構築を促す
            currentLevelNotifier.value = currentLevelNotifier.value;
            isLevelUpNotifier.value = isLevelUpNotifier.value;
            developer.log('状態変数の強制更新完了');
          }
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lv.$maxAchievableLevelまでスキップしました！'),
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
            const SnackBar(
              content: Text('既に最高レベルに到達しています。'),
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
            content: Text('スキップ処理でエラーが発生しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalTaps = useState(0);
    final currentLevel = useState(1);
    final isLevelUp = useState(false);
    final isProcessingTap = useState(false); // タップ処理中フラグ
    final tapAnimationController = useAnimationController(
      duration: AppConfig.tapAnimationDuration,
    );
    final levelUpAnimationController = useAnimationController(
      duration: AppConfig.levelUpAnimationDuration,
    );
    final levelUpNotificationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
      initialValue: 0.0,
    );
    
    // 動画再生の状態
    final isRewardedAdLoaded = useState(AdService.instance.isRewardedAdLoaded);
    
    // バナー広告の読み込み状態を監視
    final isBannerAdLoaded = useState(AdService.instance.isBannerAdLoaded);
    
    // 初期データを読み込み
    useEffect(() {
      totalTaps.value = DataService.instance.getTotalTaps();
      currentLevel.value = DataService.instance.getCurrentLevel();
      developer.log('初期データ読み込み完了: タップ数=${totalTaps.value}, レベル=${currentLevel.value}');
      return null;
    }, []);
    
    // 新しい機能の状態
    final showTutorial = useState(false);
    final showDailyChallenge = useState(false);
    final showAchievements = useState(false);
    
    // デイリーチャレンジの状態
    final dailyChallengeProgress = useState(0);
    final dailyChallengeTarget = useState(100);
    final dailyChallengeReward = useState(50);
    
    // アチーブメントの状態
    final achievements = useState<List<Map<String, dynamic>>>([]);
    
    // 広告の状態を定期的にチェック
    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        final currentBannerLoaded = AdService.instance.isBannerAdLoaded;
        final currentRewardedLoaded = AdService.instance.isRewardedAdLoaded;
        
        if (currentBannerLoaded != isBannerAdLoaded.value) {
          isBannerAdLoaded.value = currentBannerLoaded;
        }
        
        if (currentRewardedLoaded != isRewardedAdLoaded.value) {
          isRewardedAdLoaded.value = currentRewardedLoaded;
        }
      });
      
      return timer.cancel;
    }, []);

    // スクリーンショット用のキー
    final screenshotKey = useMemoized(() => GlobalKey(), []);

    // 初期化時に広告を読み込み
    useEffect(() {
      AdService.instance.loadBannerAd();
      AdService.instance.loadRewardedAd();
      
      // 動画広告の読み込み状態を監視
      final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        isRewardedAdLoaded.value = AdService.instance.isRewardedAdLoaded;
      });
      
      return () => timer.cancel();
    }, []);

    // データの変更を監視し、定期的に状態を更新
    useEffect(() {
      final timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        final newTotalTaps = DataService.instance.getTotalTaps();
        final newCurrentLevel = DataService.instance.getCurrentLevel();
        
        if (newTotalTaps != totalTaps.value) {
          totalTaps.value = newTotalTaps;
        }
        
        if (newCurrentLevel != currentLevel.value) {
          currentLevel.value = newCurrentLevel;
        }
      });
      
      return () => timer.cancel();
    }, []);



    // アチーブメントを更新する関数
    void updateAchievements() {
      final newAchievements = <Map<String, dynamic>>[];
      
      // レベルアチーブメント
      if (currentLevel.value >= 10) {
        newAchievements.add({
          'title': 'レベル10達成',
          'description': 'レベル10に到達しました',
          'icon': Icons.star,
          'color': Colors.amber,
          'completed': true,
        });
      }
      
      if (currentLevel.value >= 50) {
        newAchievements.add({
          'title': 'レベル50達成',
          'description': 'レベル50に到達しました',
          'icon': Icons.star,
          'color': Colors.orange,
          'completed': true,
        });
      }
      
      if (currentLevel.value >= 100) {
        newAchievements.add({
          'title': 'レベル100達成',
          'description': 'レベル100に到達しました',
          'icon': Icons.star,
          'color': Colors.red,
          'completed': true,
        });
      }
      
      // タップ数アチーブメント
      if (totalTaps.value >= 1000) {
        newAchievements.add({
          'title': '1000タップ達成',
          'description': '1000回タップしました',
          'icon': Icons.touch_app,
          'color': Colors.blue,
          'completed': true,
        });
      }
      
      if (totalTaps.value >= 10000) {
        newAchievements.add({
          'title': '10000タップ達成',
          'description': '10000回タップしました',
          'icon': Icons.touch_app,
          'color': Colors.green,
          'completed': true,
        });
      }
      
      achievements.value = newAchievements;
    }



    // アチーブメントを更新
    useEffect(() {
      updateAchievements();
      return null;
    }, [totalTaps.value, currentLevel.value]);

    // デイリーチャレンジを開始
    void startDailyChallenge() {
      showDailyChallenge.value = true;
      dailyChallengeProgress.value = 0;
      dailyChallengeTarget.value = 100 + (currentLevel.value * 10);
      dailyChallengeReward.value = 50 + (currentLevel.value * 5);
    }

    // デイリーチャレンジを完了
    void completeDailyChallenge() {
      if (dailyChallengeProgress.value >= dailyChallengeTarget.value) {
        // 報酬を付与
        final reward = dailyChallengeReward.value;
        final newTotalTaps = totalTaps.value + reward;
        totalTaps.value = newTotalTaps;
        DataService.instance.saveTotalTaps(newTotalTaps);
        
        showDailyChallenge.value = false;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('デイリーチャレンジ完了！${reward}タップを獲得しました'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }

    // 動画再生ボタンの処理（ポップアップ表示）
    void onWatchAd() async {
      if (isRewardedAdLoaded.value) {
        // 確認ダイアログを表示
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('動画広告'),
            content: const Text('動画広告を視聴して報酬を獲得しますか？\n\n視聴完了後、100タップを獲得できます。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('視聴する'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          developer.log('=== 動画再生開始 ===');
          developer.log('現在の総タップ数: ${totalTaps.value}');
          developer.log('現在の実際タップ数: ${DataService.instance.getRealTapCount()}');
          developer.log('現在の統計タップ数: ${await StatsService.instance.getTodayTaps()}');
          developer.log('現在の実際統計タップ数: ${await StatsService.instance.getTodayActualTaps()}');
          
          final success = await AdService.instance.showRewardedAd();
          developer.log('動画再生結果: $success');
          
          // 動画再生後に少し待ってから報酬状態を再確認
          await Future.delayed(const Duration(milliseconds: 1000));
          
          if (success) {
            developer.log('=== 動画報酬処理開始 ===');
            // 動画視聴完了時の報酬（100タップ追加）
            final rewardTaps = 100;
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
            await StatsService.instance.recordTodayActualTaps(100);
            developer.log('実際タップ数統計記録完了');
            
            // 実際のタップ数（倍率なし）を記録
            final currentRealTaps = DataService.instance.getRealTapCount();
            final newRealTaps = currentRealTaps + 100;
            await DataService.instance.saveRealTapCount(newRealTaps);
            developer.log('実際タップ数保存完了');
            
            // 保存後の確認
            final savedRealTaps = DataService.instance.getRealTapCount();
            developer.log('保存後の実際タップ数確認: $savedRealTaps');
            
            // 少し待ってからUIを更新（保存の反映を待つ）
            await Future.delayed(const Duration(milliseconds: 100));
            
            // UIを更新
            totalTaps.value = DataService.instance.getTotalTaps();
            developer.log('UI更新後の総タップ数: ${totalTaps.value}');

            // リワード広告を再読み込み
            await AdService.instance.loadRewardedAd();
            
            // リアルタイム更新を強制実行
            totalTaps.value = DataService.instance.getTotalTaps();
            developer.log('強制更新後の総タップ数: ${totalTaps.value}');
            
            developer.log('=== 動画報酬処理完了 ===');
            developer.log('最終確認 - 総タップ数: ${DataService.instance.getTotalTaps()}, 実際タップ数: ${DataService.instance.getRealTapCount()}');

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('動画視聴完了！${actualReward}タップを獲得しました'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            developer.log('動画再生失敗 - 報酬が獲得されませんでした');
            // 動画視聴に失敗した場合
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('動画視聴に失敗しました。報酬は獲得できませんでした。'),
                  backgroundColor: Colors.red,
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
            const SnackBar(
              content: Text('動画広告の読み込み中です。しばらく待ってから再試行してください。'),
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
          text: '絶対ムリタップでレベル${currentLevel.value}、総タップ数${totalTaps.value}回達成！ランキングに参加しよう！',
        );
      } finally {
        // 共有完了後、広告を再表示
        AdService.instance.showAd();
      }
    }

    // タップ処理
    void onTap() async {
      // 既に処理中の場合は無視
      if (isProcessingTap.value) {
        return;
      }
      
      // 処理中フラグを設定
      isProcessingTap.value = true;
      
      try {
        // タップアニメーション
        tapAnimationController.forward().then((_) {
          tapAnimationController.reverse();
        });

        // 課金倍率を取得
        final tapMultiplier = await PurchaseService.instance.getTapMultiplier();
        
        // タップ数を増加（倍率を適用）
        final tapIncrement = 1 * tapMultiplier;
        final newTotalTaps = totalTaps.value + tapIncrement;
        totalTaps.value = newTotalTaps;

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
        if (showDailyChallenge.value) {
          dailyChallengeProgress.value += tapIncrement;
          if (dailyChallengeProgress.value >= dailyChallengeTarget.value) {
            completeDailyChallenge();
          }
        }

        // レベルアップ判定（現在のレベルで判定）
        final currentLevelForCheck = DataService.instance.getCurrentLevel();
        if (DataService.instance.isLevelUp(newTotalTaps, currentLevelForCheck)) {
          final newLevel = currentLevelForCheck + 1;
          currentLevel.value = newLevel;
          
          // レベルアップデータを保存
          await DataService.instance.saveCurrentLevel(newLevel);
          if (newLevel > DataService.instance.getHighestLevel()) {
            await DataService.instance.saveHighestLevel(newLevel);
          }

          // レベルアップ演出
          isLevelUp.value = true;
          levelUpAnimationController.forward().then((_) {
            levelUpAnimationController.reverse();
            isLevelUp.value = false;
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
        }
      } catch (e) {
        developer.log('Error in tap processing: $e');
      } finally {
        // 処理完了後、少し待ってからフラグをリセット（デバウンス）
        Future.delayed(const Duration(milliseconds: 50), () {
          isProcessingTap.value = false;
        });
      }
    }

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(
              'MURITAP',
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
                      showTutorial.value = true;
                      break;
                                          case 'challenge':
                        startDailyChallenge();
                        break;
                    case 'achievements':
                      showAchievements.value = true;
                      break;

                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'tutorial',
                    child: Row(
                      children: [
                        Icon(Icons.help_outline),
                        SizedBox(width: 8),
                        Text('チュートリアル'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'challenge',
                    child: Row(
                      children: [
                        Icon(Icons.emoji_events),
                        SizedBox(width: 8),
                        Text('デイリーチャレンジ'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'achievements',
                    child: Row(
                      children: [
                        Icon(Icons.workspace_premium),
                        SizedBox(width: 8),
                        Text('アチーブメント'),
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
                  color: isRewardedAdLoaded.value 
                    ? ThemeConfig.primaryColor 
                    : Colors.grey,
                ),
                tooltip: '動画を見て報酬を獲得',
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
                              'Lv.${currentLevel.value}',
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
                            color: TitleService.instance.getTitleColor(currentLevel.value).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: TitleService.instance.getTitleColor(currentLevel.value),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                TitleService.instance.getTitleIcon(currentLevel.value),
                                color: TitleService.instance.getTitleColor(currentLevel.value),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                TitleService.instance.getTitle(currentLevel.value),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: TitleService.instance.getTitleColor(currentLevel.value),
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
                          'TOTAL TAPS',
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
                            _formatTapCount(totalTaps.value, context),
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
                              'NEXT LEVEL',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[400],
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              'Lv.${currentLevel.value + 1}',
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
                          value: _getProgressFactor(currentLevel.value, totalTaps.value),
                          backgroundColor: Colors.grey[800],
                          valueColor: AlwaysStoppedAnimation<Color>(ThemeConfig.primaryColor),
                          minHeight: 6,
                        ),
                        const SizedBox(height: 4),
                        // 次のレベルまでの残りタップ数
                        Builder(
                          builder: (context) {
                            final nextLevelRequired = DataService.instance.getRequiredTapsForLevel(currentLevel.value + 1);
                            final remainingTaps = nextLevelRequired - totalTaps.value;
                            
                            // 既に次のレベルに達している場合
                            if (remainingTaps <= 0) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '次のレベルに到達済み！',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: ThemeConfig.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => _skipToCurrentLevel(context, totalTaps.value, totalTaps, currentLevel, isLevelUp, levelUpAnimationController),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: ThemeConfig.primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      minimumSize: const Size(0, 32),
                                    ),
                                    child: const Text(
                                      'スキップ',
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
                              'あと${remainingTaps}回でレベルアップ！',
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
                  if (showDailyChallenge.value)
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
                                'デイリーチャレンジ',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                              Text(
                                '報酬: ${dailyChallengeReward.value}タップ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: dailyChallengeProgress.value / dailyChallengeTarget.value,
                            backgroundColor: Colors.grey[800],
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                            minHeight: 6,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${dailyChallengeProgress.value}/${dailyChallengeTarget.value}',
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
                          isProcessing: isProcessingTap.value,
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
                        'LEVEL UP! Lv.${currentLevel.value}',
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
        if (showTutorial.value)
          _buildTutorialDialog(context, () => showTutorial.value = false),
        
        // アチーブメントダイアログ
        if (showAchievements.value)
          _buildAchievementsDialog(context, () => showAchievements.value = false),
        

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
              'チュートリアル',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ThemeConfig.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            _buildTutorialStep(
              icon: Icons.touch_app,
              title: 'タップしてレベルアップ',
              description: '中央のボタンをタップしてレベルを上げましょう。レベルが上がると称号が変わります。',
            ),
            const SizedBox(height: 16),
            _buildTutorialStep(
              icon: Icons.play_circle_outline,
              title: '動画で報酬獲得',
              description: '動画広告を視聴して100タップの報酬を獲得できます。',
            ),
            const SizedBox(height: 16),
            _buildTutorialStep(
              icon: Icons.emoji_events,
              title: 'デイリーチャレンジ',
              description: '毎日のチャレンジをクリアして特別な報酬を獲得しましょう。',
            ),
            const SizedBox(height: 16),
            _buildTutorialStep(
              icon: Icons.workspace_premium,
              title: 'アチーブメント',
              description: '様々な目標を達成してアチーブメントを解除しましょう。',
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
              child: const Text('理解しました'),
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
              'アチーブメント',
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
                future: _getAchievements(),
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
              child: const Text('閉じる'),
            ),
          ],
        ),
      ),
    );
  }

  // アチーブメントを取得
  Future<List<Map<String, dynamic>>> _getAchievements() async {
    final currentLevel = DataService.instance.getCurrentLevel();
    final totalTaps = DataService.instance.getTotalTaps();
    final newAchievements = <Map<String, dynamic>>[];
    
    // レベルアチーブメント
    if (currentLevel >= 10) {
      newAchievements.add({
        'title': 'レベル10達成',
        'description': 'レベル10に到達しました',
        'icon': Icons.star,
        'color': Colors.amber,
        'completed': true,
      });
    }
    
    if (currentLevel >= 50) {
      newAchievements.add({
        'title': 'レベル50達成',
        'description': 'レベル50に到達しました',
        'icon': Icons.star,
        'color': Colors.orange,
        'completed': true,
      });
    }
    
    if (currentLevel >= 100) {
      newAchievements.add({
        'title': 'レベル100達成',
        'description': 'レベル100に到達しました',
        'icon': Icons.star,
        'color': Colors.red,
        'completed': true,
      });
    }
    
    // タップ数アチーブメント
    if (totalTaps >= 1000) {
      newAchievements.add({
        'title': '1000タップ達成',
        'description': '1000回タップしました',
        'icon': Icons.touch_app,
        'color': Colors.blue,
        'completed': true,
      });
    }
    
    if (totalTaps >= 10000) {
      newAchievements.add({
        'title': '10000タップ達成',
        'description': '10000回タップしました',
        'icon': Icons.touch_app,
        'color': Colors.green,
        'completed': true,
      });
    }
    
    return newAchievements;
  }


} 