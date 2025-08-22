# MURITAP テスト実行ガイド

このドキュメントでは、MURITAPアプリケーションの自動テストの実行方法について説明します。

## 📋 テスト構成

### テスト種類
- **単体テスト** (`test/unit/`): サービス層のビジネスロジックをテスト
- **ウィジェットテスト** (`test/widget/`): UIコンポーネントの動作をテスト
- **統合テスト** (`integration_test/`): アプリ全体のフローをテスト

### テストファイル構造
```
test/
├── unit/
│   └── services/
│       ├── data_service_test.dart      # データ管理テスト
│       ├── stats_service_test.dart     # 統計サービステスト
│       └── title_service_test.dart     # 称号システムテスト
├── widget/
│   ├── widgets/
│   │   ├── tap_button_test.dart        # タップボタンテスト
│   │   └── level_display_test.dart     # レベル表示テスト
│   └── screens/
│       └── home_screen_test.dart       # ホーム画面テスト
├── integration/
│   └── app_flow_test.dart              # アプリフローテスト
└── test_helpers/
    └── mock_services.dart              # テスト用モッククラス
```

## 🚀 テスト実行方法

### 1. 自動テストスクリプトを使用（推奨）
```bash
# プロジェクトルートで実行
./test_runner.sh
```

このスクリプトは以下を自動実行します：
- 依存関係のインストール
- コード解析
- 全テストの実行
- カバレッジレポート生成

### 2. 個別テスト実行

#### 全テスト実行
```bash
flutter test --coverage
```

#### 単体テストのみ
```bash
flutter test test/unit/
```

#### ウィジェットテストのみ
```bash
flutter test test/widget/
```

#### 特定のテストファイル
```bash
flutter test test/unit/services/data_service_test.dart
```

#### 統合テスト
```bash
flutter test integration_test/
```

### 3. VSCode内での実行

VSCodeでテストファイルを開き、CodeLensの「Run」ボタンをクリックするか：
- `Ctrl+Shift+P` → "Flutter: Run Flutter Tests"

## 📊 テストカバレッジ

### カバレッジレポート確認
```bash
# HTMLレポート生成（lcovが必要）
genhtml coverage/lcov.info -o coverage/html

# ブラウザで表示（macOS）
open coverage/html/index.html
```

### lcovのインストール
```bash
# macOS
brew install lcov

# Ubuntu/Debian
sudo apt-get install lcov
```

### VSCode拡張機能
Coverage Gutters拡張をインストールすると、エディタ内でカバレッジを視覚的に確認できます。

## 🔧 テスト環境設定

### 必要な依存関係
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.10
  integration_test:
    sdk: flutter
```

### モックファイル生成
```bash
dart run build_runner build --delete-conflicting-outputs
```

## 🤖 CI/CD (GitHub Actions)

### 自動テスト実行
プッシュ時やプルリクエスト作成時に自動でテストが実行されます：
- `.github/workflows/test.yml`

### テスト結果の確認
1. GitHubのActionsタブでテスト結果を確認
2. カバレッジレポートはアーティファクトとしてダウンロード可能
3. Codecovでカバレッジの推移を確認

## 📝 テスト作成ガイドライン

### 単体テスト
- 各サービスクラスの公開メソッドをテスト
- 境界値テストを含める
- エラーケースもテスト

### ウィジェットテスト
- ユーザー操作（タップ、スクロール）をテスト
- 状態変化を確認
- アニメーションの動作確認

### 統合テスト
- 完全なユーザーフローをテスト
- 実際のデバイスでの動作確認
- パフォーマンステストも含める

## 🛠️ トラブルシューティング

### よくある問題

#### 1. モック生成エラー
```bash
# キャッシュをクリア
flutter clean
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

#### 2. テスト実行時のメモリエラー
```bash
# メモリ使用量を制限
flutter test --concurrency=1
```

#### 3. 統合テストでデバイスが見つからない
```bash
# デバイス一覧確認
flutter devices

# エミュレーターを起動
flutter emulators --launch <emulator_id>
```

## 📈 テスト戦略

### 目標
- **単体テスト**: ビジネスロジックの100%カバレッジ
- **ウィジェットテスト**: 主要UIコンポーネントの動作確認
- **統合テスト**: 主要なユーザーフロー網羅

### 継続的改善
- 新機能追加時は必ずテストも追加
- バグ修正時は回帰テストを追加
- カバレッジ低下を防ぐ

## 🏁 まとめ

このテストフレームワークにより、MURITAPアプリケーションの品質向上と安定性確保を実現します。定期的なテスト実行により、バグの早期発見と修正が可能になります。

質問や問題がある場合は、プロジェクトのIssueで報告してください。