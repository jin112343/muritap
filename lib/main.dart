import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


// アプリケーションの設定
import 'config/app_config.dart';
import 'config/theme_config.dart';

// 画面
import 'screens/home_screen.dart';
import 'screens/ranking_screen.dart';
import 'screens/settings_screen.dart';

// サービス
import 'services/data_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 広告の初期化
  await MobileAds.instance.initialize();
  
  // データサービスの初期化
  await DataService.instance.initialize();
  
  runApp(const ImpossibleTapApp());
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
