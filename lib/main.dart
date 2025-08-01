import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

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
    print('=== アプリ初期化開始 ===');
    
    // データサービスの初期化
    print('データサービス初期化開始');
    await DataService.instance.initialize();
    print('データサービス初期化完了');
    
    // 課金サービスの初期化
    print('課金サービス初期化開始');
    await PurchaseService.instance.initialize();
    print('課金サービス初期化完了');
    
    // 広告サービスの初期化（動画再生機能含む）
    print('広告サービス初期化開始');
    await AdService.instance.initialize();
    
    // 広告削除状態をチェックして広告の表示を制御
    await AdService.instance.updateAdVisibility();
    print('広告サービス初期化完了');
    
    // 通知サービスの初期化
    print('通知サービス初期化開始');
    await NotificationService.instance.initialize();
    
    // アプリ起動時にすべての通知をクリア
    await NotificationService.instance.clearAllNotifications();
    print('通知をクリアしました');
    print('通知サービス初期化完了');
    
    // トラッキング許可の要求（iOS 14.5以降）
    await _requestTrackingAuthorization();
    
    // 購入イベントのリスナーを設定
    _setupPurchaseListener();
    
    print('=== アプリ初期化完了 ===');
  } catch (e) {
    print('アプリ初期化エラー: $e');
  }
}

/// 購入イベントのリスナーを設定
void _setupPurchaseListener() {
  final Stream<List<PurchaseDetails>> purchaseUpdated = InAppPurchase.instance.purchaseStream;
  
  purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
    _handlePurchaseUpdates(purchaseDetailsList);
  }, onDone: () {
    print('購入ストリーム終了');
  }, onError: (error) {
    print('購入ストリームエラー: $error');
  });
}

/// 購入更新を処理
Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) async {
  print('購入更新イベントを受信: ${purchaseDetailsList.length}件');
  
  for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
    print('購入詳細処理開始: ${purchaseDetails.productID} - ステータス: ${purchaseDetails.status}');
    
    if (purchaseDetails.status == PurchaseStatus.pending) {
      print('購入処理中: ${purchaseDetails.productID}');
    } else if (purchaseDetails.status == PurchaseStatus.purchased ||
               purchaseDetails.status == PurchaseStatus.restored) {
      print('購入完了: ${purchaseDetails.productID}');
      print('購入詳細: ${purchaseDetails.purchaseID}');
      
      // 購入状態を保存
      await PurchaseService.instance.setProductPurchased(purchaseDetails.productID);
      print('購入状態を保存完了: ${purchaseDetails.productID}');
      
      // 広告削除の場合は広告の表示状態を更新
      if (purchaseDetails.productID == PurchaseService.removeAds) {
        print('広告削除購入のため、広告表示状態を更新');
        await AdService.instance.updateAdVisibility();
      }
      
      // 購入完了を確認
      await InAppPurchase.instance.completePurchase(purchaseDetails);
      print('購入完了処理完了: ${purchaseDetails.productID}');
      
      print('購入処理完了: ${purchaseDetails.productID}');
    } else if (purchaseDetails.status == PurchaseStatus.error) {
      print('購入エラー: ${purchaseDetails.error}');
      print('エラー詳細: ${purchaseDetails.error?.message}');
      print('エラーコード: ${purchaseDetails.error?.code}');
    } else if (purchaseDetails.status == PurchaseStatus.canceled) {
      print('購入キャンセル: ${purchaseDetails.productID}');
    } else {
      print('不明な購入ステータス: ${purchaseDetails.status}');
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
      print('Tracking authorization status: $status');
    }
  } catch (e) {
    print('Error requesting tracking authorization: $e');
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
