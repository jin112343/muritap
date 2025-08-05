# 絶対ムリタップ

蓄積型の中毒系タップアプリ「絶対ムリタップ」のFlutter版です。

## 🎯 アプリ概要

「絶対ムリ」と思えるタップ数に挑戦し続ける、シンプルなタップゲームです。

### 主な機能

- **累積タップ数**: タップするたびに累積数が増加
- **レベルシステム**: 数式ベースのレベル計算（Lv.1〜999）
- **レベルアップ演出**: レベルアップ時の色変化とアニメーション
- **称号システム**: レベルに応じて変化する称号
- **デイリーチャレンジ**: 毎日の目標をクリアして特別な報酬を獲得
- **アチーブメント**: 様々な目標を達成してアチーブメントを解除
- **統計機能**: 日別・週別・月別のタップ統計を確認
- **チュートリアル**: 初心者向けの使い方ガイド
- **GameCenter連携**: iOSでのランキング機能
- **広告表示**: AdMobバナー広告とリワード広告
- **データ保存**: ローカルでの安全なデータ保存

## 🏗️ アーキテクチャ

### 機密性（Confidentiality）
- データは端末内にのみ保存
- 外部への個人情報送信なし
- 設定値の一元管理

### 完全性（Integrity）
- システム内完結の設計
- データの整合性チェック機能
- エラーハンドリングによる安定性確保

### 可用性（Availability）
- 広告読み込み失敗時もアプリ動作継続
- GameCenter未対応環境でも動作
- エラー発生時の適切なフォールバック

## 📁 ファイル構成

```
lib/
├── config/           # 設定ファイル
│   ├── app_config.dart
│   └── theme_config.dart
├── services/         # サービス層
│   ├── data_service.dart
│   ├── ad_service.dart
│   ├── stats_service.dart
│   ├── title_service.dart
│   └── game_center_service.dart
├── screens/          # 画面
│   ├── home_screen.dart
│   ├── ranking_screen.dart
│   └── settings_screen.dart
├── widgets/          # 再利用可能ウィジェット
│   ├── tap_button.dart
│   ├── level_display.dart
│   └── stats_display.dart
└── main.dart         # エントリーポイント
```

## 🚀 セットアップ

### 前提条件

- Flutter SDK 3.8.1以上
- Dart SDK 3.8.1以上
- Android Studio / Xcode

### インストール手順

1. **依存関係のインストール**
   ```bash
   flutter pub get
   ```

2. **Android設定**
   - `android/app/src/main/AndroidManifest.xml`でAdMob設定を確認
   - 本番用の広告IDを設定

3. **iOS設定**
   - `ios/Runner/Info.plist`でアプリ名を確認
   - GameCenter連携のため、実際のリーダーボードIDを設定

4. **アプリの実行**
   ```bash
   flutter run
   ```

## 📦 使用パッケージ

| パッケージ名 | 用途 | バージョン |
|-------------|------|-----------|
| `shared_preferences` | ローカルデータ保存 | ^2.2.2 |
| `google_mobile_ads` | AdMob広告表示 | ^6.0.0 |
| `in_app_purchase` | 課金機能 | ^3.1.13 |
| `flutter_hooks` | 状態管理 | ^0.20.5 |
| `url_launcher` | 外部リンク | ^6.2.4 |
| `share_plus` | 共有機能 | ^11.0.0 |
| `flutter_local_notifications` | 通知機能 | ^19.4.0 |

## 🎮 ゲームシステム

### レベル計算式

```dart
int getRequiredTapsForLevel(int level) {
  const base = 10;
  const growthRate = 2.0;
  return (base * pow(level, growthRate)).floor();
}
```

- Lv.1: 0タップ
- Lv.2: 約20タップ
- Lv.10: 約2,000タップ
- Lv.100: 約200,000タップ
- Lv.999: 約2,000,000タップ

### 新機能詳細

#### デイリーチャレンジ
- 毎日新しい目標が設定される
- 目標達成で特別な報酬を獲得
- レベルに応じて難易度が調整

#### アチーブメント
- レベル達成アチーブメント
- タップ数達成アチーブメント
- 継続的な目標設定

#### 統計機能
- 今日のタップ数
- 今週のタップ数
- 今月のタップ数
- 詳細な統計データ

#### チュートリアル
- 初心者向けガイド
- 機能の使い方説明
- 段階的な学習

### 画面構成

1. **ホーム画面**: メインのタップ機能と新機能
2. **ランキング画面**: GameCenter連携（iOS限定）
3. **設定画面**: アプリ情報と外部リンク

## 🔧 開発・保守

### コード品質

- **保守性**: モジュール化されたファイル構成
- **可読性**: 明確な命名規則とコメント
- **拡張性**: プラグインアーキテクチャ

### テスト

```bash
# ユニットテスト実行
flutter test

# ウィジェットテスト実行
flutter test test/widget_test.dart
```

### ビルド

```bash
# Android APK
flutter build apk

# iOS
flutter build ios
```

## 📱 対応プラットフォーム

- **Android**: API 21以上
- **iOS**: iOS 11.0以上
- **GameCenter**: iOSのみ対応

## 🔒 プライバシー・セキュリティ

- 個人情報の外部送信なし
- データは端末内にのみ保存
- 広告はGoogle AdMobを使用
- GameCenter連携はユーザー同意後

## 📄 ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## 🤝 貢献

バグ報告や機能要望は、設定画面の「お問い合わせ」からお送りください。

---

**絶対ムリタップ** - タップの限界に挑戦しよう！
