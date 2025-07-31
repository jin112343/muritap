import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import '../config/app_config.dart';
import '../config/theme_config.dart';
import '../services/data_service.dart';
import '../services/purchase_service.dart';
import '../services/stats_service.dart';
import '../widgets/stats_chart.dart';
import 'webview_screen.dart';
import '../services/ad_service.dart';

/// 設定画面
/// アプリ情報と外部リンクを提供
class SettingsScreen extends HookWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 統計データをリアルタイムで監視
    final totalTaps = useState(DataService.instance.getTotalTaps());
    final currentLevel = useState(DataService.instance.getCurrentLevel());
    final todayTaps = useState<int>(0);
    final todayActualTaps = useState<int>(0);
    
    final isLoading = useState(false);
    final weeklyStats = useState<List<DailyStats>>([]);
    final monthlyStats = useState<List<DailyStats>>([]);
    final isLoadingStats = useState(true);
    final isPurchaseAvailable = useState(false);
    
    // TabControllerを作成
    final tabController = useTabController(initialLength: 2);

    // 統計データを定期的に更新
    useEffect(() {
      // 初期データを読み込み
      StatsService.instance.getTodayTaps().then((value) {
        todayTaps.value = value;
      });
      
      StatsService.instance.getTodayActualTaps().then((value) {
        todayActualTaps.value = value;
      });
      
      // 統計データを初期読み込み
      Future.wait([
        StatsService.instance.getThisWeekStats(),
        StatsService.instance.getLast30DaysStats(),
      ]).then((results) {
        weeklyStats.value = results[0];
        monthlyStats.value = results[1];
        isLoadingStats.value = false;
      });
      
      // 初期データを強制更新
      totalTaps.value = DataService.instance.getTotalTaps();
      currentLevel.value = DataService.instance.getCurrentLevel();
      
      final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        // 今日の統計データを非同期で更新
        StatsService.instance.getTodayTaps().then((value) {
          if (value != todayTaps.value) {
            todayTaps.value = value;
          }
        });
        
        StatsService.instance.getTodayActualTaps().then((value) {
          if (value != todayActualTaps.value) {
            todayActualTaps.value = value;
          }
        });
        
        // 週間・月間統計を定期的に更新（10秒間隔）
        if (timer.tick % 10 == 0) {
          Future.wait([
            StatsService.instance.getThisWeekStats(),
            StatsService.instance.getLast30DaysStats(),
          ]).then((results) {
            weeklyStats.value = results[0];
            monthlyStats.value = results[1];
          });
        }
        
        // 強制的にデータを更新（1秒間隔）
        totalTaps.value = DataService.instance.getTotalTaps();
        currentLevel.value = DataService.instance.getCurrentLevel();
      });
      
      return timer.cancel;
    }, []);

    // 課金機能の状態を監視
    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        isPurchaseAvailable.value = PurchaseService.instance.isAvailable;
      });
      
      return () => timer.cancel();
    }, []);

    // 課金ボタンの処理
    void onPurchase() async {
      if (isPurchaseAvailable.value) {
        // 課金画面を表示
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('課金商品'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 広告削除
                  FutureBuilder<bool>(
                    future: PurchaseService.instance.isProductPurchased(PurchaseService.removeAds),
                    builder: (context, snapshot) {
                      final isPurchased = snapshot.data ?? false;
                      return ListTile(
                        leading: Icon(
                          PurchaseService.instance.getProductIcon(PurchaseService.removeAds),
                          color: isPurchased ? Colors.green : PurchaseService.instance.getProductColor(PurchaseService.removeAds),
                        ),
                        title: Text(PurchaseService.instance.getProductDisplayName(PurchaseService.removeAds)),
                        subtitle: Text(PurchaseService.instance.getProductDescription(PurchaseService.removeAds)),
                        trailing: isPurchased 
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : Text(PurchaseService.instance.getProductPrice(PurchaseService.removeAds)),
                        onTap: isPurchased ? null : () async {
                          Navigator.of(context).pop();
                          final success = await PurchaseService.instance.purchaseByTap(PurchaseService.removeAds);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success ? '広告削除を購入しました！' : '購入に失敗しました'),
                                backgroundColor: success ? Colors.green : Colors.red,
                              ),
                            );
                            // 購入成功時は広告の表示状態を更新
                            if (success) {
                              await AdService.instance.updateAdVisibility();
                            }
                          }
                        },
                      );
                    },
                  ),
                  // 1タップ10回
                  FutureBuilder<bool>(
                    future: PurchaseService.instance.isProductPurchased(PurchaseService.tap10),
                    builder: (context, snapshot) {
                      final isPurchased = snapshot.data ?? false;
                      return ListTile(
                        leading: Icon(
                          PurchaseService.instance.getProductIcon(PurchaseService.tap10),
                          color: isPurchased ? Colors.green : PurchaseService.instance.getProductColor(PurchaseService.tap10),
                        ),
                        title: Text(PurchaseService.instance.getProductDisplayName(PurchaseService.tap10)),
                        subtitle: Text(PurchaseService.instance.getProductDescription(PurchaseService.tap10)),
                        trailing: isPurchased 
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : Text(PurchaseService.instance.getProductPrice(PurchaseService.tap10)),
                        onTap: isPurchased ? null : () async {
                          Navigator.of(context).pop();
                          final success = await PurchaseService.instance.purchaseByTap(PurchaseService.tap10);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success ? '1タップ10回を購入しました！' : '購入に失敗しました'),
                                backgroundColor: success ? Colors.green : Colors.red,
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                  // 1タップ100回
                  FutureBuilder<bool>(
                    future: PurchaseService.instance.isProductPurchased(PurchaseService.tap100),
                    builder: (context, snapshot) {
                      final isPurchased = snapshot.data ?? false;
                      return ListTile(
                        leading: Icon(
                          PurchaseService.instance.getProductIcon(PurchaseService.tap100),
                          color: isPurchased ? Colors.green : PurchaseService.instance.getProductColor(PurchaseService.tap100),
                        ),
                        title: Text(PurchaseService.instance.getProductDisplayName(PurchaseService.tap100)),
                        subtitle: Text(PurchaseService.instance.getProductDescription(PurchaseService.tap100)),
                        trailing: isPurchased 
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : Text(PurchaseService.instance.getProductPrice(PurchaseService.tap100)),
                        onTap: isPurchased ? null : () async {
                          Navigator.of(context).pop();
                          final success = await PurchaseService.instance.purchaseByTap(PurchaseService.tap100);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success ? '1タップ100回を購入しました！' : '購入に失敗しました'),
                                backgroundColor: success ? Colors.green : Colors.red,
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                  // 1タップ1000回
                  FutureBuilder<bool>(
                    future: PurchaseService.instance.isProductPurchased(PurchaseService.tap1000),
                    builder: (context, snapshot) {
                      final isPurchased = snapshot.data ?? false;
                      return ListTile(
                        leading: Icon(
                          PurchaseService.instance.getProductIcon(PurchaseService.tap1000),
                          color: isPurchased ? Colors.green : PurchaseService.instance.getProductColor(PurchaseService.tap1000),
                        ),
                        title: Text(PurchaseService.instance.getProductDisplayName(PurchaseService.tap1000)),
                        subtitle: Text(PurchaseService.instance.getProductDescription(PurchaseService.tap1000)),
                        trailing: isPurchased 
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : Text(PurchaseService.instance.getProductPrice(PurchaseService.tap1000)),
                        onTap: isPurchased ? null : () async {
                          Navigator.of(context).pop();
                          final success = await PurchaseService.instance.purchaseByTap(PurchaseService.tap1000);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success ? '1タップ1000回を購入しました！' : '購入に失敗しました'),
                                backgroundColor: success ? Colors.green : Colors.red,
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('閉じる'),
                ),
              ],
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('課金機能が利用できません'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    // 外部リンクを開く
    Future<void> openUrl(String url) async {
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('リンクを開けませんでした'),
                backgroundColor: ThemeConfig.errorColor,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('エラーが発生しました: $e'),
              backgroundColor: ThemeConfig.errorColor,
            ),
          );
        }
      }
    }

    // メールを開く
    Future<void> launchEmail() async {
      final subject = Uri.encodeComponent('絶対ムリタップについて');
      final body = Uri.encodeComponent('''
お問い合わせ内容：



---
アプリ名: 絶対ムリタップ
バージョン: ${AppConfig.appVersion}
''');
      final emailUrl = 'mailto:mizoijin.0201@gmail.com?subject=$subject&body=$body';
      await openUrl(emailUrl);
    }

    // 統計データを読み込み
    useEffect(() {
      return null;
    }, []);

    // データをリセット
    Future<void> resetData() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('データリセット'),
          content: const Text('すべてのデータが削除されます。\nこの操作は取り消せません。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: ThemeConfig.errorColor,
              ),
              child: const Text('リセット'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        isLoading.value = true;
        try {
          await DataService.instance.resetData();
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('データをリセットしました'),
                backgroundColor: ThemeConfig.successColor,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('リセットに失敗しました: $e'),
                backgroundColor: ThemeConfig.errorColor,
              ),
            );
          }
        } finally {
          isLoading.value = false;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: '設定'),
            Tab(text: '統計'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          // 設定タブ
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // アプリ情報
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.touch_app,
                          size: 64,
                          color: ThemeConfig.primaryColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppConfig.appName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 課金セクション
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.shopping_cart,
                          color: isPurchaseAvailable.value 
                            ? ThemeConfig.primaryColor 
                            : Colors.grey,
                        ),
                        title: const Text('課金商品'),
                        subtitle: const Text('広告削除やタップ倍率アップ'),
                        onTap: onPurchase,
                        trailing: isPurchaseAvailable.value 
                          ? const Icon(Icons.arrow_forward_ios, size: 16)
                          : const Icon(Icons.error_outline, color: Colors.grey, size: 16),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // サポート
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.email),
                        title: const Text('お問い合わせ'),
                        subtitle: const Text('バグ報告や機能要望'),
                        onTap: launchEmail,
                      ),
                      ListTile(
                        leading: const Icon(Icons.privacy_tip),
                        title: const Text('プライバシーポリシー'),
                        subtitle: const Text('個人情報の取り扱い'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const WebViewScreen(
                                title: 'プライバシーポリシー',
                                url: AppConfig.privacyPolicyUrl,
                              ),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.description),
                        title: const Text('利用規約'),
                        subtitle: const Text('アプリの利用条件'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const WebViewScreen(
                                title: '利用規約',
                                url: AppConfig.termsOfServiceUrl,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // データ管理
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.delete_forever, color: ThemeConfig.errorColor),
                        title: const Text('データリセット'),
                        subtitle: const Text('すべてのデータを削除'),
                        onTap: isLoading.value ? null : resetData,
                        trailing: isLoading.value 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32), // 下部に余白を追加
              ],
            ),
          ),
          
          // 統計タブ
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 統計情報
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.analytics,
                              color: ThemeConfig.primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '統計情報',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: ThemeConfig.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // 今日のタップ数
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '今日の統計タップ数',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '${todayTaps.value} 回',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ThemeConfig.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // 総タップ数
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '総タップ数',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '${totalTaps.value} 回',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ThemeConfig.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // 実際のタップ数（倍率なし）
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '今日の実際のタップ数',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '${todayActualTaps.value} 回',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ThemeConfig.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // 現在のレベル
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '現在のレベル',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'Lv.${currentLevel.value}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ThemeConfig.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // 現在のタップ倍率
                        FutureBuilder<int>(
                          future: PurchaseService.instance.getTapMultiplier(),
                          builder: (context, snapshot) {
                            final multiplier = snapshot.data ?? 1;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '現在のタップ倍率',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.flash_on,
                                      color: multiplier > 1 ? Colors.orange : Colors.grey,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${multiplier}x',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: multiplier > 1 ? Colors.orange : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 今週の統計グラフ
                if (!isLoadingStats.value) ...[
                  StatsChart(
                    stats: weeklyStats.value,
                    title: '今週の記録（月曜日から）',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 30日間の統計グラフ
                  StatsChart(
                    stats: monthlyStats.value,
                    title: '過去30日間の記録',
                    barColor: ThemeConfig.accentColor,
                    isScrollable: true,
                  ),
                ] else ...[
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
} 