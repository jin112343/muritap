import 'package:flutter/material.dart';

import '../config/theme_config.dart';
import '../services/data_service.dart';

/// レベル表示ウィジェット
/// 現在のレベルとレベルアップ演出を表示
class LevelDisplay extends StatelessWidget {
  final int currentLevel;
  final int totalTaps;
  final bool isLevelUp;
  final AnimationController animationController;

  const LevelDisplay({
    super.key,
    required this.currentLevel,
    required this.totalTaps,
    required this.isLevelUp,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final nextLevelTaps = DataService.instance.getRequiredTapsForLevel(currentLevel + 1);
    final currentLevelTaps = DataService.instance.getRequiredTapsForLevel(currentLevel);
    final progress = nextLevelTaps > currentLevelTaps 
      ? (totalTaps - currentLevelTaps) / (nextLevelTaps - currentLevelTaps)
      : 1.0;

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        final color = isLevelUp 
          ? Color.lerp(
              ThemeConfig.primaryColor,
              ThemeConfig.successColor,
              animationController.value,
            )!
          : ThemeConfig.primaryColor;

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // レベル表示
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: isLevelUp ? 30 : 15,
                      spreadRadius: isLevelUp ? 8 : 3,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  'Lv.$currentLevel',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // プログレスバー
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '次のレベルまで',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${totalTaps - currentLevelTaps} / ${nextLevelTaps - currentLevelTaps}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
} 