import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:developer' as developer;

// アプリケーションの設定
import 'config/app_config.dart';
import 'config/theme_config.dart';

// 画面
import 'screens/home_screen.dart';
import 'screens/ranking_screen.dart';
import 'screens/settings_screen.dart';

// サービス
import 'services/data_service.dart';
import 'services/ad_service.dart';
import 'services/purchase_service.dart';
import 'services/tracking_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // アプリの初期化
  await _initializeApp();
  
  runApp(const ImpossibleTapApp());
}

/// アプリの初期化処理
Future<void> _initializeApp() async {
  try {
    developer.log('=== アプリ初期化開始 ===');
    
    // データサービスの初期化
    developer.log('データサービス初期化開始');
    await DataService.instance.initialize();
    developer.log('データサービス初期化完了');
    
    // 課金サービスの初期化
    developer.log('課金サービス初期化開始');
    await PurchaseService.instance.initialize();
    developer.log('課金サービス初期化完了');
    
    // 広告サービスの初期化（動画再生機能含む）
    developer.log('広告サービス初期化開始');
    await AdService.instance.initialize();
    
    // 広告削除状態をチェックして広告の表示を制御
    await AdService.instance.updateAdVisibility();
    developer.log('広告サービス初期化完了');
    
    // 通知サービスの初期化
    developer.log('通知サービス初期化開始');
    await NotificationService.instance.initialize();
    
    // アプリ起動時にすべての通知をクリア
    await NotificationService.instance.clearAllNotifications();
    developer.log('通知をクリアしました');
    
    // 少し待ってからバッジをクリア（確実性のため）
    await Future.delayed(const Duration(milliseconds: 500));
    await NotificationService.instance.clearBadge();
    developer.log('バッジをクリアしました');
    
    // 毎日20時の通知をスケジュール
    await NotificationService.instance.scheduleDailyNotification();
    developer.log('毎日20時の通知をスケジュールしました');
    
    developer.log('通知サービス初期化完了');
    
    // トラッキング許可の要求（iOS 14.5以降）
    await _requestTrackingAuthorization();
    
    // 購入イベントのリスナーを設定
    _setupPurchaseListener();
    
    developer.log('=== アプリ初期化完了 ===');
  } catch (e) {
    developer.log('アプリ初期化エラー: $e');
  }
}

/// 購入イベントのリスナーを設定
void _setupPurchaseListener() {
  final Stream<List<PurchaseDetails>> purchaseUpdated = InAppPurchase.instance.purchaseStream;
  
  purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
    _handlePurchaseUpdates(purchaseDetailsList);
  }, onDone: () {
    developer.log('購入ストリーム終了');
  }, onError: (error) {
    developer.log('購入ストリームエラー: $error');
  });
}

/// 購入更新を処理
Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) async {
  developer.log('購入更新イベントを受信: ${purchaseDetailsList.length}件');
  
  for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
    developer.log('購入詳細処理開始: ${purchaseDetails.productID} - ステータス: ${purchaseDetails.status}');
    
    if (purchaseDetails.status == PurchaseStatus.pending) {
      developer.log('購入処理中: ${purchaseDetails.productID}');
    } else if (purchaseDetails.status == PurchaseStatus.purchased ||
               purchaseDetails.status == PurchaseStatus.restored) {
      developer.log('購入完了: ${purchaseDetails.productID}');
      developer.log('購入詳細: ${purchaseDetails.purchaseID}');
      
      // 購入状態を保存
      await PurchaseService.instance.setProductPurchased(purchaseDetails.productID);
      developer.log('購入状態を保存完了: ${purchaseDetails.productID}');
      
      // 広告削除の場合は広告の表示状態を更新
      if (purchaseDetails.productID == PurchaseService.removeAds) {
        developer.log('広告削除購入のため、広告表示状態を更新');
        await AdService.instance.updateAdVisibility();
      }
      
      // 購入完了を確認
      await InAppPurchase.instance.completePurchase(purchaseDetails);
      developer.log('購入完了処理完了: ${purchaseDetails.productID}');
      
      developer.log('購入処理完了: ${purchaseDetails.productID}');
    } else if (purchaseDetails.status == PurchaseStatus.error) {
      developer.log('購入エラー: ${purchaseDetails.error}');
      developer.log('エラー詳細: ${purchaseDetails.error?.message}');
      developer.log('エラーコード: ${purchaseDetails.error?.code}');
    } else if (purchaseDetails.status == PurchaseStatus.canceled) {
      developer.log('購入キャンセル: ${purchaseDetails.productID}');
    } else {
      developer.log('不明な購入ステータス: ${purchaseDetails.status}');
    }
  }
}

/// トラッキング許可を要求
Future<void> _requestTrackingAuthorization() async {
  try {
    // トラッキング許可が必要かどうかを確認
    final shouldRequest = await TrackingService.instance.shouldRequestTracking();
    if (shouldRequest) {
      // 許可を要求
      final status = await TrackingService.instance.requestTrackingAuthorization();
      developer.log('Tracking authorization status: $status');
    }
  } catch (e) {
    developer.log('Error requesting tracking authorization: $e');
  }
}

class ImpossibleTapApp extends HookWidget {
  const ImpossibleTapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      theme: ThemeConfig.darkTheme,
      themeMode: ThemeMode.dark,
      home: const MainNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationScreen extends HookWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentIndex = useState(1); // ホーム画面を初期表示
    
    final screens = [
      const RankingScreen(),
      const HomeScreen(),
      const SettingsScreen(),
    ];
    
    return Scaffold(
      body: IndexedStack(
        index: currentIndex.value,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: ThemeConfig.surfaceColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex.value,
          onTap: (index) => currentIndex.value = index,
          backgroundColor: Colors.transparent,
          selectedItemColor: ThemeConfig.primaryColor,
          unselectedItemColor: Colors.grey[400],
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard),
              label: 'ランキング',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'ホーム',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: '設定',
            ),
          ],
        ),
      ),
    );
  }
}
