import 'package:flutter/material.dart';
import '../config/theme_config.dart';

/// 統計情報表示ウィジェット
/// 累積タップ数とレベル情報を表示
class StatsDisplay extends StatelessWidget {
  final int totalTaps;
  final int currentLevel;

  const StatsDisplay({
    super.key,
    required this.totalTaps,
    required this.currentLevel,
  });

    @override
  Widget build(BuildContext context) {
    // タップ数の表示形式を計算
    String tapDisplayText;
    String tapSubText = '';
    
    if (totalTaps >= 10000) {
      final thousands = (totalTaps / 1000).floor();
      final remainder = totalTaps % 1000;
      
      if (thousands >= 10000) {
        final tenThousands = (thousands / 10000).floor();
        final thousandsRemainder = thousands % 10000;
        tapDisplayText = '${tenThousands}万${thousandsRemainder}千';
      } else {
        tapDisplayText = '${thousands}千';
      }
      
      if (remainder > 0) {
        tapSubText = remainder.toString();
      }
    } else {
      tapDisplayText = totalTaps.toString();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ThemeConfig.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ThemeConfig.primaryColor.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            // タップ数表示（大きく）
            Text(
              tapDisplayText,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: ThemeConfig.primaryColor,
                shadows: [
                  Shadow(
                    color: ThemeConfig.primaryColor.withValues(alpha: 0.5),
                    blurRadius: 10,
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
            ),
            if (tapSubText.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                tapSubText,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: ThemeConfig.primaryColor.withValues(alpha: 0.7),
                  shadows: [
                    Shadow(
                      color: ThemeConfig.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            const Text(
              '累積タップ数',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 