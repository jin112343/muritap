import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:developer' as developer;
import '../config/app_config.dart';
import '../config/theme_config.dart';
import '../services/data_service.dart';
import '../services/purchase_service.dart';
import '../services/stats_service.dart';
import '../widgets/stats_chart.dart';
import 'webview_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../l10n/app_localizations.dart';

/// 設定画面
/// アプリ情報と外部リンクを提供
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  // 統計データをリアルタイムで監視
  int totalTaps = 0;
  int currentLevel = 1;
  int todayTaps = 0;
  int todayActualTaps = 0;

  List<DailyStats> weeklyStats = [];
  List<DailyStats> monthlyStats = [];
  bool isLoadingStats = true;
  bool isPurchaseAvailable = false;

  // 通知設定の状態
  bool isDailyNotificationEnabled = false;

  // TabController
  late TabController tabController;

  // タイマー
  Timer? _statsTimer;
  Timer? _purchaseTimer;

  // 商品カード用の状態変数
  bool isLoadingRemoveAds = false;
  String? selectedProductIdRemoveAds;
  final Map<String, bool> isLoadingMap = {};
  final Map<String, String?> selectedProductIdMap = {};

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    
    // 初期データを読み込み
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });

    // 統計データを定期的に更新
    _statsTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateStatsData();
    });

    // 課金機能の状態を監視
    _purchaseTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        isPurchaseAvailable = PurchaseService.instance.isAvailable;
      });
    });
  }

  @override
  void dispose() {
    _statsTimer?.cancel();
    _purchaseTimer?.cancel();
    tabController.dispose();
    super.dispose();
  }

  // 初期データを読み込み
  void _initializeData() {
    _initializeDataWithLocalization();
  }

  // 統計データを更新
  Future<void> _updateStatsData() async {
    try {
      // 今日の統計データを非同期で更新
      final todayTapsValue = await StatsService.instance.getTodayTaps();
      final todayActualTapsValue =
          await StatsService.instance.getTodayActualTaps();

      if (todayTapsValue != todayTaps) {
        setState(() {
          todayTaps = todayTapsValue;
        });
      }

      if (todayActualTapsValue != todayActualTaps) {
        setState(() {
          todayActualTaps = todayActualTapsValue;
        });
      }

      // 強制的にデータを更新
      setState(() {
        totalTaps = DataService.instance.getTotalTaps();
        currentLevel = DataService.instance.getCurrentLevel();
      });
    } catch (e) {
      developer.log('統計データ更新エラー: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // TabBar
          Container(
            color: ThemeConfig.surfaceColor,
            child: TabBar(
              controller: tabController,
              tabs: [
                Tab(text: AppLocalizations.of(context)!.settingsTabsSettings),
                Tab(text: AppLocalizations.of(context)!.settingsTabsStats),
                Tab(text: AppLocalizations.of(context)!.settingsTabsPurchase),
              ],
            ),
          ),
          // TabBarView
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                // 設定タブ
                _buildSettingsTab(
                  context,
                  currentLevel,
                  isDailyNotificationEnabled,
                ),
                // 統計タブ
                _buildStatsTab(
                  totalTaps,
                  currentLevel,
                  todayTaps,
                  todayActualTaps,
                  weeklyStats,
                  monthlyStats,
                  isLoadingStats,
                ),
                // 購入タブ
                _buildPurchaseTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 初期データの読み込み
  Future<void> _initializeDataWithLocalization() async {
    try {
      // 今日の統計データを読み込み
      final todayTapsValue = await StatsService.instance.getTodayTaps();
      final todayActualTapsValue =
          await StatsService.instance.getTodayActualTaps();

      // 統計データを初期読み込み
      final results = await Future.wait([
        StatsService.instance.getThisWeekStats(
          monday: AppLocalizations.of(context)!.weekdayMonday,
          tuesday: AppLocalizations.of(context)!.weekdayTuesday,
          wednesday: AppLocalizations.of(context)!.weekdayWednesday,
          thursday: AppLocalizations.of(context)!.weekdayThursday,
          friday: AppLocalizations.of(context)!.weekdayFriday,
          saturday: AppLocalizations.of(context)!.weekdaySaturday,
          sunday: AppLocalizations.of(context)!.weekdaySunday,
        ),
        StatsService.instance.getLast30DaysStats(
          monday: AppLocalizations.of(context)!.weekdayMonday,
          tuesday: AppLocalizations.of(context)!.weekdayTuesday,
          wednesday: AppLocalizations.of(context)!.weekdayWednesday,
          thursday: AppLocalizations.of(context)!.weekdayThursday,
          friday: AppLocalizations.of(context)!.weekdayFriday,
          saturday: AppLocalizations.of(context)!.weekdaySaturday,
          sunday: AppLocalizations.of(context)!.weekdaySunday,
        ),
      ]);

      // 強制的にデータを更新
      setState(() {
        todayTaps = todayTapsValue;
        todayActualTaps = todayActualTapsValue;
        weeklyStats = results[0];
        monthlyStats = results[1];
        isLoadingStats = false;
        totalTaps = DataService.instance.getTotalTaps();
        currentLevel = DataService.instance.getCurrentLevel();
      });

      // 通知設定の状態を確認
      final scheduled =
          await NotificationService.instance.isDailyNotificationScheduled();
      setState(() {
        isDailyNotificationEnabled = scheduled;
      });
    } catch (e) {
      developer.log('初期データ読み込みエラー: $e');
    }
  }

  /// 設定タブのWidget
  Widget _buildSettingsTab(
      BuildContext context,
      int currentLevel,
      bool isDailyNotificationEnabled,
      ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // アプリ情報
          _buildAppInfoCard(),
          const SizedBox(height: 16),
          // サポート
          _buildSupportCard(context),
          const SizedBox(height: 16),
          // アプリ情報詳細
          _buildAppDetailsCard(currentLevel),
          const SizedBox(height: 16),
          // データ管理
          _buildDataManagementCard(context),
          const SizedBox(height: 16),
          // 通知設定
          _buildNotificationCard(context, isDailyNotificationEnabled),
        ],
      ),
    );
  }

  /// アプリ情報カード
  Widget _buildAppInfoCard() {
    return Card(
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
    );
  }

  /// サポートカード
  Widget _buildSupportCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.email),
            title: Text(AppLocalizations.of(context)!.settingsContact),
            subtitle: Text(AppLocalizations.of(context)!.settingsContactDescription),
            onTap: () => _launchEmail(context),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: Text(AppLocalizations.of(context)!.settingsPrivacyPolicy),
            subtitle: Text(AppLocalizations.of(context)!.settingsPrivacyDescription),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => WebViewScreen(
                    title: AppLocalizations.of(context)!.settingsPrivacyPolicy,
                    url: AppConfig.privacyPolicyUrl,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: Text(AppLocalizations.of(context)!.settingsTermsOfService),
            subtitle: Text(AppLocalizations.of(context)!.settingsTermsDescription),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => WebViewScreen(
                    title: AppLocalizations.of(context)!.settingsTermsOfService,
                    url: AppConfig.termsOfServiceUrl,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// アプリ詳細情報カード
  Widget _buildAppDetailsCard(int currentLevel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.settingsAppInfoTitle,
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
                  AppLocalizations.of(context)!.settingsCurrentLevel,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Lv.${currentLevel}',
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
                      AppLocalizations.of(context)!.settingsCurrentTapMultiplier,
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
    );
  }

  /// データ管理カード
  Widget _buildDataManagementCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: Text(AppLocalizations.of(context)!.settingsDeleteData),
            subtitle: Text(AppLocalizations.of(context)!.settingsDeleteDataDescription),
            onTap: () => _showDataDeleteDialog(context),
          ),
        ],
      ),
    );
  }

  /// 通知設定カード
  Widget _buildNotificationCard(
      BuildContext context,
      bool isDailyNotificationEnabled,
      ) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              isDailyNotificationEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color: isDailyNotificationEnabled
                  ? ThemeConfig.primaryColor
                  : Colors.grey,
            ),
            title: Text(AppLocalizations.of(context)!.settingsDailyNotification),
            subtitle: Text(AppLocalizations.of(context)!.settingsDailyNotificationDescription),
            trailing: Switch(
              value: isDailyNotificationEnabled,
              onChanged: (value) => _toggleNotification(
                context,
                value,
              ),
              activeColor: ThemeConfig.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 統計タブのWidget
  Widget _buildStatsTab(
      int totalTaps,
      int currentLevel,
      int todayTaps,
      int todayActualTaps,
      List<DailyStats> weeklyStats,
      List<DailyStats> monthlyStats,
      bool isLoadingStats,
      ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 今日の統計
          _buildTodayStatsCard(
            totalTaps,
            currentLevel,
            todayTaps,
            todayActualTaps,
          ),
          const SizedBox(height: 16),

          // 統計グラフ
          if (!isLoadingStats) ...[
            StatsChart(
              stats: weeklyStats,
              title: AppLocalizations.of(context)!.settingsWeeklyRecordTitle,
            ),
            const SizedBox(height: 16),
            StatsChart(
              stats: monthlyStats,
              title: AppLocalizations.of(context)!.settingsMonthlyRecordTitle,
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
    );
  }

  /// 今日の統計カード
  Widget _buildTodayStatsCard(
      int totalTaps,
      int currentLevel,
      int todayTaps,
      int todayActualTaps,
      ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.settingsTodayStatsTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeConfig.primaryColor,
              ),
            ),
            const SizedBox(height: 12),

            _buildStatRow(AppLocalizations.of(context)!.settingsTodayTaps, '${todayTaps}', ThemeConfig.primaryColor),
            const SizedBox(height: 8),
            _buildStatRow(AppLocalizations.of(context)!.settingsTodayActualTaps, '${todayActualTaps}', ThemeConfig.accentColor),
            const SizedBox(height: 8),
            _buildStatRow(AppLocalizations.of(context)!.settingsTotalTaps, '${totalTaps}', ThemeConfig.primaryColor),
            const SizedBox(height: 8),
            _buildStatRow(AppLocalizations.of(context)!.settingsCurrentLevelLabel, 'Lv.${currentLevel}', ThemeConfig.primaryColor),
          ],
        ),
      ),
    );
  }

  /// 統計行のWidget
  Widget _buildStatRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  /// 購入タブのWidget
  Widget _buildPurchaseTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 購入商品の説明
          _buildPurchaseDescriptionCard(),
          const SizedBox(height: 16),

          // 購入商品一覧
          ..._buildProductList(context),

          const SizedBox(height: 16),

          // 購入履歴復元ボタン
          _buildRestorePurchasesCard(context),
        ],
      ),
    );
  }



  /// 購入説明カード
  Widget _buildPurchaseDescriptionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.settingsPurchaseTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeConfig.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.settingsPurchaseDescription,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 商品リストの構築
  List<Widget> _buildProductList(BuildContext context) {
    final productWidgets = <Widget>[];

    // 広告削除を一番上に表示
    if (PurchaseService.instance.products.any(
            (p) => p.id == PurchaseService.removeAds)) {
      productWidgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildProductCard(
            context,
            PurchaseService.removeAds,
            isLoadingMap[PurchaseService.removeAds] ?? false,
            selectedProductIdMap[PurchaseService.removeAds],
          ),
        ),
      );
    }

    // その他の商品を金額順（安い順）で表示
    final otherProducts = PurchaseService.instance.products
        .where((product) => product.id != PurchaseService.removeAds)
        .map((product) => product.id)
        .toList();

    otherProducts.sort((a, b) {
      final priceA = _getProductPriceValue(a);
      final priceB = _getProductPriceValue(b);
      return priceA.compareTo(priceB);
    });

    productWidgets.addAll(
      otherProducts.map((productId) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildProductCard(
            context,
            productId,
            isLoadingMap[productId] ?? false,
            selectedProductIdMap[productId],
          ),
        );
      }).toList(), // ← .toList() を追加
    );

    return productWidgets;
  }

  /// 購入履歴復元カード
  Widget _buildRestorePurchasesCard(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.restore, color: Colors.blue),
        title: Text(AppLocalizations.of(context)!.purchaseRestorePurchases),
        subtitle: Text(AppLocalizations.of(context)!.purchaseRestorePurchasesDescription),
        onTap: () => _restorePurchases(context),
      ),
    );
  }

  /// 商品カードのWidget
  Widget _buildProductCard(
      BuildContext context,
      String productId,
      bool isLoading,
      String? selectedProductId,
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
                            PurchaseService.instance
                                .getProductDisplayName(productId, context),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ThemeConfig.textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            PurchaseService.instance
                                .getProductDescription(productId, context),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isPurchased)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 24,
                      )
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
                    onPressed: isLoading
                        ? null
                        : () => _purchaseProduct(
                      context,
                      productId,
                    ),
                    icon: const Icon(Icons.payment),
                    label: Text(AppLocalizations.of(context)!.purchaseButton),
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
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
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
                          AppLocalizations.of(context)!.settingsPurchased,
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

  /// メール送信機能
  static Future<void> _launchEmail(BuildContext context) async {
    try {
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
                                        SnackBar(
                              content: Text(AppLocalizations.of(context)!.settingsEmailAppError),
                              backgroundColor: Colors.red,
                            ),
          );
        }
      }
    } catch (e, stackTrace) {
              developer.log('メール送信エラー: $e\nスタックトレース: $stackTrace');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
                            content: Text(AppLocalizations.of(context)!.settingsEmailSendError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 購入データをクリア
  static Future<void> _clearPurchaseData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // 購入関連のキーを削除
      await prefs.remove('purchased_removeads');
      await prefs.remove('purchased_tap10');
      await prefs.remove('purchased_tap100');
      await prefs.remove('purchased_tap1000');
              developer.log('購入データをクリアしました');
      } catch (e, stackTrace) {
        developer.log('購入データクリアエラー: $e\nスタックトレース: $stackTrace');
    }
  }

  /// すべてのデータを削除
  static Future<void> _deleteAllData(BuildContext context) async {
    try {
      // データをリセット
      await DataService.instance.resetData();

      // 統計データもリセット
      await StatsService.instance.clearStats();

      // 購入データもリセット（購入データは永続化されるため、手動でクリア）
      await _clearPurchaseData();

      // 画面を更新
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
              content: Text(AppLocalizations.of(context)!.settingsDataDeleteSuccess),
              backgroundColor: Colors.green,
            ),
        );
      }
    } catch (e, stackTrace) {
              developer.log('データ削除エラー: $e\nスタックトレース: $stackTrace');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
                            content: Text(AppLocalizations.of(context)!.settingsDataDeleteError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// データ削除の確認ダイアログを表示
  static void _showDataDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.settingsDataDeleteConfirmTitle),
          content: Text(
            AppLocalizations.of(context)!.settingsDataDeleteConfirmContent,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.settingsDataDeleteConfirmCancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteAllData(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text(AppLocalizations.of(context)!.settingsDataDeleteConfirmDelete),
            ),
          ],
        );
      },
    );
  }

  /// 通知の有効/無効を切り替え
  Future<void> _toggleNotification(
      BuildContext context,
      bool value,
      ) async {
    try {
      if (value) {
        // 通知を有効化
        await NotificationService.instance.scheduleDailyNotification(context);
        setState(() {
          isDailyNotificationEnabled = true;
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.settingsNotificationEnabled),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // 通知を無効化
        await NotificationService.instance.cancelDailyNotification();
        setState(() {
          isDailyNotificationEnabled = false;
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.settingsNotificationDisabled),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      developer.log('通知設定変更エラー: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
                            content: Text(AppLocalizations.of(context)!.settingsNotificationSettingError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 購入処理
  Future<void> _purchaseProduct(
      BuildContext context,
      String productId,
      ) async {
    setState(() {
      isLoadingMap[productId] = true;
      selectedProductIdMap[productId] = productId;
    });

    try {
      developer.log('実際の課金処理開始 - 商品ID: $productId');
      
      // 高額商品（3万円以上）の場合は年齢確認を先に行う - 一時的に無効化
      // if (productId == PurchaseService.tap1M || productId == PurchaseService.tap100M) {
      //   developer.log('=== 高額商品の年齢確認開始（設定画面） ===');
      //   developer.log('商品ID: $productId');
      //   
      //   try {
      //     developer.log('年齢確認ダイアログを表示します');
      //     final isAgeVerified = await PurchaseService.instance.showAgeVerificationDialog(context);
      //     developer.log('年齢確認結果: $isAgeVerified');
      //   
      //       if (!isAgeVerified) {
      //         developer.log('年齢確認が拒否されました');
      //         if (context.mounted) {
      //           ScaffoldMessenger.of(context).showSnackBar(
      //             const SnackBar(
      //               content: Text('年齢確認が完了していないため、購入できません。\n高額商品（3万円以上）は20歳以上の方のみ購入可能です。'),
      //               backgroundColor: Colors.orange,
      //               duration: Duration(seconds: 5),
      //             ),
      //           );
      //         }
      //         developer.log('年齢確認拒否により購入処理を停止');
      //         return;
      //       }
      //       developer.log('年齢確認が承認されました');
      //     } catch (e) {
      //       developer.log('年齢確認ダイアログでエラーが発生: $e');
      //       developer.log('エラーの詳細: ${e.toString()}');
      //       return;
      //     }
      //     developer.log('=== 高額商品の年齢確認完了（設定画面） ===');
      //   } else {
      //     developer.log('通常商品のため年齢確認は不要');
      //   }

      final success = await PurchaseService.instance
          .purchaseWithRealPayment(productId);

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.settingsPurchaseSuccess(PurchaseService.instance.getProductDisplayName(productId, context)),
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
              content: Text(AppLocalizations.of(context)!.settingsPurchaseFailed),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      developer.log('購入処理でエラーが発生: $e\nスタックトレース: $stackTrace');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
              content: Text(AppLocalizations.of(context)!.settingsPurchaseError),
              backgroundColor: Colors.red,
            ),
        );
      }
    } finally {
      setState(() {
        isLoadingMap[productId] = false;
        selectedProductIdMap[productId] = null;
      });
    }
  }

  /// 購入履歴復元
  static Future<void> _restorePurchases(BuildContext context) async {
    try {
      await PurchaseService.instance.restorePurchases();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.purchaseRestoreStarted),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e, stackTrace) {
      developer.log('購入履歴復元エラー: $e\nスタックトレース: $stackTrace');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.purchaseRestoreFailedRetry),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 商品の価格を数値で取得（ソート用）
  static int _getProductPriceValue(String productId) {
    if (productId == PurchaseService.removeAds) {
      return 100; // 100円
    } else if (productId == PurchaseService.tap10) {
      return 100; // 100円
    } else if (productId == PurchaseService.tap100) {
      return 300; // 300円
    } else if (productId == PurchaseService.tap1000) {
      return 1000; // 1,000円
    }
    // else if (productId == PurchaseService.tap1M) {
    //   return 30000; // 30,000円
    // } else if (productId == PurchaseService.tap100M) {
    //   return 150000; // 150,000円
    // }
    else {
      return 9999; // 不明な商品は最後に表示
    }
  }
}