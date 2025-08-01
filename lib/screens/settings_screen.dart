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
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

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
    
    final weeklyStats = useState<List<DailyStats>>([]);
    final monthlyStats = useState<List<DailyStats>>([]);
    final isLoadingStats = useState(true);
    final isPurchaseAvailable = useState(false);
    
    // 通知設定の状態
    final isDailyNotificationEnabled = useState(false);
    
    // TabControllerを作成
    final tabController = useTabController(initialLength: 3);

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
      
      // 通知設定の状態を確認
      NotificationService.instance.isDailyNotificationScheduled().then((scheduled) {
        isDailyNotificationEnabled.value = scheduled;
      });
      
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
      
      return () => timer.cancel;
    }, []);

    // メール送信機能
    void launchEmail() async {
      final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: AppConfig.supportEmail,
        query: 'subject=${Uri.encodeComponent('絶対ムリタップ - お問い合わせ')}',
      );
      
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('メールアプリを開けませんでした'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }



    // 購入データをクリア
    Future<void> clearPurchaseData() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        // 購入関連のキーを削除
        await prefs.remove('purchased_removeads');
        await prefs.remove('purchased_tap10');
        await prefs.remove('purchased_tap100');
        await prefs.remove('purchased_tap1000');
        print('購入データをクリアしました');
      } catch (e) {
        print('購入データクリアエラー: $e');
      }
    }

    // すべてのデータを削除
    Future<void> deleteAllData() async {
      try {
        // データをリセット
        await DataService.instance.resetData();
        
        // 統計データもリセット
        await StatsService.instance.clearStats();
        
        // 購入データもリセット（購入データは永続化されるため、手動でクリア）
        await clearPurchaseData();
        
        // 画面を更新
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('すべてのデータを削除しました'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        print('データ削除エラー: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('データ削除中にエラーが発生しました: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    // データ削除の確認ダイアログを表示
    void showDataDeleteDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('データ削除の確認'),
            content: const Text(
              'すべてのデータ（タップ数、レベル、統計など）が削除されます。\n'
              'この操作は取り消すことができません。\n\n'
              '本当に削除しますか？',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await deleteAllData();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('削除'),
              ),
            ],
          );
        },
      );
    }

    return Column(
      children: [
        // カスタムAppBar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Text(
                '設定',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: ThemeConfig.textColor,
                ),
              ),
            ],
          ),
        ),
        // TabBar
        Container(
          color: ThemeConfig.surfaceColor,
          child: TabBar(
            controller: tabController,
            tabs: const [
              Tab(text: '設定'),
              Tab(text: '統計'),
              Tab(text: '購入'),
            ],
          ),
        ),
        // TabBarView
        Expanded(
          child: TabBarView(
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
                    
                    // アプリ情報
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'アプリ情報',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ThemeConfig.primaryColor,
                              ),
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
                    
                    // データ管理
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.delete_forever, color: Colors.red),
                            title: const Text('データを削除'),
                            subtitle: const Text('すべてのデータをリセット'),
                            onTap: () {
                              showDataDeleteDialog(context);
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 通知設定
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(
                              isDailyNotificationEnabled.value 
                                ? Icons.notifications_active 
                                : Icons.notifications_off,
                              color: isDailyNotificationEnabled.value 
                                ? ThemeConfig.primaryColor 
                                : Colors.grey,
                            ),
                            title: const Text('毎日20時の通知'),
                            subtitle: const Text('毎日20時にタップを促す通知'),
                            trailing: Switch(
                              value: isDailyNotificationEnabled.value,
                              onChanged: (value) async {
                                if (value) {
                                  // 通知を有効化
                                  await NotificationService.instance.scheduleDailyNotification();
                                  isDailyNotificationEnabled.value = true;
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('毎日20時の通知を有効にしました'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } else {
                                  // 通知を無効化
                                  await NotificationService.instance.cancelDailyNotification();
                                  isDailyNotificationEnabled.value = false;
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('毎日20時の通知を無効にしました'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  }
                                }
                              },
                              activeColor: ThemeConfig.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // 統計タブ
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 今日の統計
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '今日の統計',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ThemeConfig.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // 今日のタップ数
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '今日のタップ数',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '${todayTaps.value}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeConfig.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // 今日の実際のタップ数
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
                                  '${todayActualTaps.value}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeConfig.accentColor,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 8),
                            
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
                                  '${totalTaps.value}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeConfig.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 8),
                            
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
              
              // 購入タブ
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 購入商品の説明
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '課金商品',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ThemeConfig.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '広告削除やタップ倍率アップなどの機能を購入できます。',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 購入商品一覧
                    ...[
                      // 広告削除を一番上に表示
                      if (PurchaseService.instance.products.any((p) => p.id == PurchaseService.removeAds))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildProductCard(
                            context,
                            PurchaseService.removeAds,
                            useState(false),
                            useState<String?>(null),
                          ),
                        ),
                      // その他の商品を金額順（安い順）で表示
                      ...(() {
                        final productIds = PurchaseService.instance.products
                            .where((product) => product.id != PurchaseService.removeAds)
                            .map((product) => product.id)
                            .toList();
                        
                        productIds.sort((a, b) {
                          // 商品IDから価格を取得して比較
                          final priceA = _getProductPriceValue(a);
                          final priceB = _getProductPriceValue(b);
                          return priceA.compareTo(priceB);
                        });
                        
                        return productIds.map((productId) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _buildProductCard(
                              context,
                              productId,
                              useState(false),
                              useState<String?>(null),
                            ),
                          );
                        });
                      })(),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    // 購入履歴復元ボタン
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.restore, color: Colors.blue),
                        title: const Text('購入履歴を復元'),
                        subtitle: const Text('以前の購入を復元します'),
                        onTap: () async {
                          try {
                            await PurchaseService.instance.restorePurchases();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('購入履歴の復元を開始しました'),
                                  backgroundColor: Colors.blue,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('復元に失敗しました: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    String productId,
    ValueNotifier<bool> isLoading,
    ValueNotifier<String?> selectedProductId,
  ) {
    return FutureBuilder<bool>(
      future: PurchaseService.instance.isProductPurchased(productId),
      builder: (context, snapshot) {
        final isPurchased = snapshot.data ?? false;
        
        return Card(
          elevation: 4,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      PurchaseService.instance.getProductIcon(productId),
                      color: isPurchased 
                        ? Colors.green 
                        : PurchaseService.instance.getProductColor(productId),
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            PurchaseService.instance.getProductDisplayName(productId),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ThemeConfig.textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            PurchaseService.instance.getProductDescription(productId),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isPurchased)
                      const Icon(Icons.check_circle, color: Colors.green, size: 24)
                    else
                      Text(
                        PurchaseService.instance.getProductPrice(productId),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ThemeConfig.primaryColor,
                        ),
                      ),
                  ],
                ),
                
                if (!isPurchased) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isLoading.value 
                        ? null 
                        : () => _purchaseProduct(context, productId, isLoading, selectedProductId),
                      icon: const Icon(Icons.payment),
                      label: const Text('購入する'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeConfig.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '購入済み',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _purchaseProduct(
    BuildContext context,
    String productId,
    ValueNotifier<bool> isLoading,
    ValueNotifier<String?> selectedProductId,
  ) async {
    isLoading.value = true;
    selectedProductId.value = productId;
    
    try {
      print('=== 実際の課金処理開始 ===');
      print('商品ID: $productId');
      
      final success = await PurchaseService.instance.purchaseWithRealPayment(productId);
      
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${PurchaseService.instance.getProductDisplayName(productId)}を購入しました！'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('購入に失敗しました。詳細はコンソールログを確認してください。'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ 購入処理でエラーが発生: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('購入エラー: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      isLoading.value = false;
      selectedProductId.value = null;
    }
  }

  /// 商品の価格を数値で取得（ソート用）
  int _getProductPriceValue(String productId) {
    if (productId == PurchaseService.removeAds) {
      return 100; // 100円
    } else if (productId == PurchaseService.tap10) {
      return 100; // 100円
    } else if (productId == PurchaseService.tap100) {
      return 300; // 300円
    } else if (productId == PurchaseService.tap1000) {
      return 3000; // 3,000円
    } else {
      return 9999; // 不明な商品は最後に表示
    }
  }
} 