import 'package:flutter/material.dart';

/// アプリケーションのテーマ設定
/// 完全性を保つため、テーマはシステム内で完結
class ThemeConfig {
  // プライマリブラックカラー
  static const MaterialColor primaryBlack = MaterialColor(
    _blackPrimaryValue,
    <int, Color>{
      50: Color(0xFFE0E0E0),
      100: Color(0xFFB3B3B3),
      200: Color(0xFF808080),
      300: Color(0xFF4D4D4D),
      400: Color(0xFF262626),
      500: Color(_blackPrimaryValue),
      600: Color(0xFF000000),
      700: Color(0xFF000000),
      800: Color(0xFF000000),
      900: Color(0xFF000000),
    },
  );
  static const int _blackPrimaryValue = 0xFF000000;

  // ライトテーマ
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ダークテーマ（画像のようなデザイン）
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: primaryBlack,
      scaffoldBackgroundColor: const Color(0xFF0A0A0A), // zinc-950
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFF97316), // orange-500
        secondary: Color(0xFFFBBF24), // yellow-400
        onPrimary: Colors.white,
        surface: Color(0xFF18181B), // zinc-900
        onSurface: Colors.white,
        error: Color(0xFFDC2626), // red-600
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // カスタムカラー（画像に合わせて更新）
  static const Color primaryColor = Color(0xFFF97316); // orange-500
  static const Color accentColor = Color(0xFFFBBF24); // yellow-400
  static const Color successColor = Colors.green;
  static const Color warningColor = Color(0xFFF97316); // orange-500
  static const Color errorColor = Color(0xFFDC2626); // red-600
  static const Color backgroundColor = Color(0xFF0A0A0A); // zinc-950
  static const Color surfaceColor = Color(0xFF18181B); // zinc-900
  static const Color textColor = Colors.white; // テキストカラー
} 