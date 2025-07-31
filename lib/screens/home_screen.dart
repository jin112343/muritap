import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:async';

import '../config/app_config.dart';
import '../config/theme_config.dart';
import '../services/data_service.dart';
import '../services/ad_service.dart';
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
    


    // 初期化時に広告を読み込み
    useEffect(() {
      AdService.instance.loadBannerAd();
      return null;
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

    // タップ処理
    void onTap() async {
      // タップアニメーション
      tapAnimationController.forward().then((_) {
        tapAnimationController.reverse();
      });

      // タップ数を増加
      final newTotalTaps = totalTaps.value + 1;
      totalTaps.value = newTotalTaps;

      // データを保存
      await DataService.instance.saveTotalTaps(newTotalTaps);
      
      // 統計データを記録
      await StatsService.instance.recordTodayTaps(1);

      // レベルアップ判定
      if (DataService.instance.isLevelUp(newTotalTaps, currentLevel.value)) {
        final newLevel = currentLevel.value + 1;
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

        // GameCenterにスコアを送信（レベルアップ時）
        if (GameCenterService.instance.isAvailable) {
          try {
            final success = await GameCenterService.instance.submitScore(newTotalTaps);
            if (success) {
              print('Score submitted successfully: $newTotalTaps');
            } else {
              print('Failed to submit score: $newTotalTaps');
            }
          } catch (e) {
            print('Error submitting score: $e');
          }
        }
      } else {
        // レベルアップしていない場合も、一定間隔でスコアを送信
        if (newTotalTaps % 100 == 0) { // 100タップごとに送信
          if (GameCenterService.instance.isAvailable) {
            try {
              final success = await GameCenterService.instance.submitScore(newTotalTaps);
              if (success) {
                print('Score submitted periodically: $newTotalTaps');
              }
            } catch (e) {
              print('Error submitting score periodically: $e');
            }
          }
        }
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
          ),
          body: Column(
            children: [
              // レベル表示（上部）
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: const EdgeInsets.all(16),
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                    const SizedBox(height: 8),
                    Text(
                      totalTaps.value.toString(),
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              // プログレスバー（上部）
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: const EdgeInsets.all(16),
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
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _getProgressFactor(currentLevel.value, totalTaps.value),
                      backgroundColor: Colors.grey[800],
                      valueColor: AlwaysStoppedAnimation<Color>(ThemeConfig.primaryColor),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 8),
                    // 次のレベルまでの残りタップ数
                    Text(
                      'あと${DataService.instance.getRequiredTapsForLevel(currentLevel.value + 1) - totalTaps.value}回でレベルアップ！',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // スペーサー
              Expanded(
                child: Container(),
              ),
              
              // タップボタン（下部）
              Container(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: TapButton(
                    onTap: onTap,
                    animationController: tapAnimationController,
                  ),
                ),
              ),
            ],
          ),
          
          // 広告表示（画面下部）
          bottomNavigationBar: AdService.instance.getBannerAdWidget(),
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