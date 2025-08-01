import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:async';

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

  @override
  Widget build(BuildContext context) {
    final totalTaps = useState(DataService.instance.getTotalTaps());
    final currentLevel = useState(DataService.instance.getCurrentLevel());
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
          print('=== 動画再生開始 ===');
          print('現在の総タップ数: ${totalTaps.value}');
          print('現在の実際タップ数: ${DataService.instance.getRealTapCount()}');
          print('現在の統計タップ数: ${await StatsService.instance.getTodayTaps()}');
          print('現在の実際統計タップ数: ${await StatsService.instance.getTodayActualTaps()}');
          
          final success = await AdService.instance.showRewardedAd();
          print('動画再生結果: $success');
          
          // 動画再生後に少し待ってから報酬状態を再確認
          await Future.delayed(const Duration(milliseconds: 1000));
          
          if (success) {
            print('=== 動画報酬処理開始 ===');
            // 動画視聴完了時の報酬（100タップ追加）
            final rewardTaps = 100;
            final tapMultiplier = await PurchaseService.instance.getTapMultiplier();
            final actualReward = rewardTaps * tapMultiplier;
            
            print('動画報酬計算: 基本報酬=$rewardTaps, 倍率=$tapMultiplier, 実際報酬=$actualReward');
            
            final currentTotalTaps = DataService.instance.getTotalTaps();
            final newTotalTaps = currentTotalTaps + actualReward;
            print('タップ数更新: 現在=$currentTotalTaps, 追加=$actualReward, 新しい総数=$newTotalTaps');
            
            // データを順次保存
            await DataService.instance.saveTotalTaps(newTotalTaps);
            print('総タップ数保存完了');
            
            // 保存後の確認
            final savedTotalTaps = DataService.instance.getTotalTaps();
            print('保存後の総タップ数確認: $savedTotalTaps');
            
            // 統計データを記録（実際のタップ数）
            await StatsService.instance.recordTodayTaps(actualReward);
            print('統計タップ数記録完了');
            
            // 実際のタップ数も記録（倍率なし）
            await StatsService.instance.recordTodayActualTaps(100);
            print('実際タップ数統計記録完了');
            
            // 実際のタップ数（倍率なし）を記録
            final currentRealTaps = DataService.instance.getRealTapCount();
            final newRealTaps = currentRealTaps + 100;
            await DataService.instance.saveRealTapCount(newRealTaps);
            print('実際タップ数保存完了');
            
            // 保存後の確認
            final savedRealTaps = DataService.instance.getRealTapCount();
            print('保存後の実際タップ数確認: $savedRealTaps');
            
            // 少し待ってからUIを更新（保存の反映を待つ）
            await Future.delayed(const Duration(milliseconds: 100));
            
            // UIを更新
            totalTaps.value = DataService.instance.getTotalTaps();
            print('UI更新後の総タップ数: ${totalTaps.value}');

            // リワード広告を再読み込み
            await AdService.instance.loadRewardedAd();
            
            // リアルタイム更新を強制実行
            totalTaps.value = DataService.instance.getTotalTaps();
            print('強制更新後の総タップ数: ${totalTaps.value}');
            
            print('=== 動画報酬処理完了 ===');
            print('最終確認 - 総タップ数: ${DataService.instance.getTotalTaps()}, 実際タップ数: ${DataService.instance.getRealTapCount()}');

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('動画視聴完了！${actualReward}タップを獲得しました'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            print('動画再生失敗 - 報酬が獲得されませんでした');
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
                print('GameCenter: Score submitted successfully: $totalTapsForGameCenter (total taps with multiplier)');
              } else {
                print('GameCenter: Failed to submit score: $totalTapsForGameCenter');
              }
            } catch (e) {
              print('GameCenter: Error submitting score: $e');
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
                  print('GameCenter: Score submitted periodically: $totalTapsForGameCenter (total taps with multiplier)');
                } else {
                  print('GameCenter: Failed to submit score periodically: $totalTapsForGameCenter');
                }
              } catch (e) {
                print('GameCenter: Error submitting score periodically: $e');
              }
            }
          }
        }
      } catch (e) {
        print('Error in tap processing: $e');
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
                        Text(
                          totalTaps.value.toString(),
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
                              return Text(
                                '次のレベルに到達済み！',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: ThemeConfig.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
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
                  
                  // スペーサー（最小限に）
                  const SizedBox(height: 20),
                  
                  // タップボタン（下部）
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: TapButton(
                        onTap: onTap,
                        animationController: tapAnimationController,
                        isProcessing: isProcessingTap.value,
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
      ],
    );
  }
} 