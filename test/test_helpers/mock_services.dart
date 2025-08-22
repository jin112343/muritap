import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:impossible_tap/l10n/app_localizations.dart';
import 'package:impossible_tap/services/data_service.dart';
import 'package:impossible_tap/services/stats_service.dart';

// モックを生成するためのアノテーション
@GenerateMocks([
  SharedPreferences,
])
import 'mock_services.mocks.dart';

/// テスト用のモックSharedPreferencesを作成するヘルパー
class MockSharedPreferencesHelper {
  static MockSharedPreferences createMockPrefs({
    Map<String, int> intValues = const {},
    Map<String, String> stringValues = const {},
    Map<String, bool> boolValues = const {},
  }) {
    final mockPrefs = MockSharedPreferences();
    
    // int値の設定
    intValues.forEach((key, value) {
      when(mockPrefs.getInt(key)).thenReturn(value);
      when(mockPrefs.setInt(key, any)).thenAnswer((_) async => true);
    });
    
    // string値の設定
    stringValues.forEach((key, value) {
      when(mockPrefs.getString(key)).thenReturn(value);
      when(mockPrefs.setString(key, any)).thenAnswer((_) async => true);
    });
    
    // bool値の設定
    boolValues.forEach((key, value) {
      when(mockPrefs.getBool(key)).thenReturn(value);
      when(mockPrefs.setBool(key, any)).thenAnswer((_) async => true);
    });
    
    // デフォルトの戻り値設定
    when(mockPrefs.getInt(any)).thenReturn(null);
    when(mockPrefs.getString(any)).thenReturn(null);
    when(mockPrefs.getBool(any)).thenReturn(null);
    when(mockPrefs.clear()).thenAnswer((_) async => true);
    
    return mockPrefs;
  }
}

/// テスト用のWidgetアプリラッパー
class TestAppWrapper extends StatelessWidget {
  final Widget child;
  
  const TestAppWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja'),
        Locale('en'),
      ],
      locale: const Locale('ja'),
      home: Scaffold(body: child),
    );
  }
}

/// テスト用のDataServiceファクトリー
class TestDataServiceFactory {
  static DataService createWithMockPrefs(MockSharedPreferences mockPrefs) {
    // DataServiceのインスタンスを取得し、mockPrefsを注入
    final dataService = DataService.instance;
    // プライベートフィールドに直接アクセスできないため、
    // 実際のテストでは依存性注入パターンを使用することを推奨
    return dataService;
  }
}

/// テスト用の共通データ
class TestDataConstants {
  static const int defaultLevel = 5;
  static const int defaultTotalTaps = 100;
  static const int defaultRealTapCount = 50;
  
  static const Map<String, int> defaultIntPrefs = {
    'total_taps': defaultTotalTaps,
    'current_level': defaultLevel,
    'highest_level': defaultLevel,
    'real_tap_count': defaultRealTapCount,
  };
}