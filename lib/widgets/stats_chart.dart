import 'package:flutter/material.dart';
import '../services/stats_service.dart';
import '../config/theme_config.dart';

/// 統計グラフウィジェット
class StatsChart extends StatelessWidget {
  final List<DailyStats> stats;
  final String title;
  final Color? barColor;
  final bool isScrollable;

  const StatsChart({
    super.key,
    required this.stats,
    required this.title,
    this.barColor,
    this.isScrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            'データがありません',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    final maxTaps = stats.map((s) => s.taps).reduce((a, b) => a > b ? a : b);
    final maxTapsForDisplay = maxTaps == 0 ? 1 : maxTaps;

    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // タイトル
          Row(
            children: [
              Icon(
                Icons.bar_chart,
                color: ThemeConfig.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ThemeConfig.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // グラフ
          SizedBox(
            height: 120,
            child: isScrollable
                ? ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: stats.length,
                    itemBuilder: (context, idx) {
                      final stat = stats[idx];
                      final height = (stat.taps / maxTapsForDisplay) * 100;
                      final isToday = stat.date.day == DateTime.now().day &&
                          stat.date.month == DateTime.now().month &&
                          stat.date.year == DateTime.now().year;
                      final dateLabel = '${stat.date.month}/${stat.date.day}';
                      return Container(
                        width: 32,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // バー
                            Container(
                              width: 20,
                              height: height,
                              decoration: BoxDecoration(
                                color: isToday
                                    ? ThemeConfig.accentColor
                                    : (barColor ?? ThemeConfig.primaryColor),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // 日付
                            Text(
                              dateLabel,
                              style: TextStyle(
                                fontSize: 11,
                                color: isToday
                                    ? ThemeConfig.accentColor
                                    : Colors.grey[400],
                                fontWeight:
                                    isToday ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            // タップ数
                            if (stat.taps > 0) ...[
                              const SizedBox(height: 4),
                              Text(
                                stat.taps.toString(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: stats.map((stat) {
                      final height = (stat.taps / maxTapsForDisplay) * 100;
                      final isToday = stat.date.day == DateTime.now().day &&
                          stat.date.month == DateTime.now().month &&
                          stat.date.year == DateTime.now().year;
                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // バー
                            Container(
                              width: 20,
                              height: height,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: isToday
                                    ? ThemeConfig.accentColor
                                    : (barColor ?? ThemeConfig.primaryColor),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // 曜日
                            Text(
                              stat.dayName,
                              style: TextStyle(
                                fontSize: 12,
                                color: isToday
                                    ? ThemeConfig.accentColor
                                    : Colors.grey[400],
                                fontWeight:
                                    isToday ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            // タップ数
                            if (stat.taps > 0) ...[
                              const SizedBox(height: 4),
                              Text(
                                stat.taps.toString(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
          
          // 合計表示
          if (stats.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: ThemeConfig.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '合計',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[400],
                    ),
                  ),
                  Text(
                    '${stats.map((s) => s.taps).reduce((a, b) => a + b)} タップ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ThemeConfig.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
} 