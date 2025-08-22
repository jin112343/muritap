# Androidリリース版作成ガイド

このガイドでは、Flutterアプリ「MURITAP」のAndroidリリース版を作成する手順を説明します。

## 📋 前提条件

- Flutter SDKがインストールされている
- Android Studioがインストールされている
- Android SDKが設定されている
- Google Play Consoleのアカウントがある

## 🚀 リリース版作成の手順

### 1. 署名キーストアの作成

リリース版のAPKには、デジタル署名が必要です。以下のコマンドで署名キーストアを作成してください：

```bash
./create_keystore.sh
```

スクリプトの指示に従って、以下の情報を入力してください：
- キーストアのパスワード
- キーのパスワード
- キーのエイリアス
- 組織情報

**⚠️ 重要**: 作成されたキーストアファイル（`android/app/keystore.jks`）とパスワードは安全に保管してください。これらを失くすと、アプリの更新ができなくなります。

### 2. 署名設定の更新

`android/app/build.gradle.kts`ファイルの署名設定を、作成したキーストアの情報で更新してください：

```kotlin
signingConfigs {
    create("release") {
        storeFile = file("keystore.jks")
        storePassword = "実際のキーストアパスワード"
        keyAlias = "実際のキーエイリアス"
        keyPassword = "実際のキーパスワード"
    }
}
```

### 3. アプリの設定確認

リリース前に以下の設定を確認してください：

#### バージョン情報（`pubspec.yaml`）
```yaml
version: 1.0.1+2  # 適切なバージョン番号に更新
```

#### アプリID（`android/app/build.gradle.kts`）
```kotlin
applicationId = "com.example.impossible_tap"  # 実際のアプリIDに変更
```

#### アプリ名（`android/app/src/main/AndroidManifest.xml`）
```xml
android:label="MURITAP"
```

### 4. リリース版のビルド

以下のコマンドでリリース版をビルドします：

```bash
./build_release.sh
```

または、手動でビルドする場合：

```bash
flutter clean
flutter pub get
flutter build apk --release
```

### 5. ビルド結果の確認

ビルドが成功すると、以下の場所にAPKファイルが生成されます：
```
build/app/outputs/flutter-apk/app-release.apk
```

## 🧪 テスト

リリース版のAPKをテストデバイスにインストールして、以下の項目を確認してください：

- [ ] アプリが正常に起動する
- [ ] 主要な機能が動作する
- [ ] 広告が表示される
- [ ] 課金機能が動作する
- [ ] 通知が動作する
- [ ] パフォーマンスが良好である

## 📱 Google Play Consoleへのアップロード

### 1. Google Play Consoleにログイン

[Google Play Console](https://play.google.com/console)にアクセスして、開発者アカウントでログインします。

### 2. 新しいアプリを作成

1. 「アプリを作成」をクリック
2. アプリ名を入力（例：「MURITAP」）
3. アプリの種類を選択（ゲーム）
4. 無料か有料かを選択

### 3. アプリ情報を入力

- アプリの説明
- スクリーンショット
- アイコン
- カテゴリ
- コンテンツレーティング

### 4. APKファイルをアップロード

1. 「リリース」→「本番環境」を選択
2. 「新しいリリースを作成」をクリック
3. APKファイルをアップロード
4. リリースノートを入力
5. レビューを送信

## 🔒 Google Play App Signing

Google Play App Signingを使用することをお勧めします。これにより：

- アプリの署名がGoogleによって管理される
- キーストアの紛失リスクが軽減される
- アプリの更新が容易になる

設定方法は、Google Play Consoleの「セットアップ」→「アプリの署名」で確認できます。

## 📊 リリース後の監視

アプリがリリースされたら、以下の項目を監視してください：

- クラッシュレポート
- ユーザーレビュー
- インストール数
- 収益（課金アプリの場合）
- 広告収益

## 🆘 トラブルシューティング

### ビルドエラーが発生する場合

1. `flutter doctor`を実行して環境を確認
2. 依存関係を更新：`flutter pub get`
3. クリーンビルド：`flutter clean`
4. エラーメッセージを確認して対処

### 署名エラーが発生する場合

1. キーストアファイルのパスが正しいか確認
2. パスワードが正しいか確認
3. キーエイリアスが正しいか確認

### アプリがクラッシュする場合

1. ProGuardルールを確認
2. リリース版でのみ発生する問題がないか確認
3. ログを確認して原因を特定

## 📚 参考資料

- [Flutter公式ドキュメント - Android リリース](https://docs.flutter.dev/deployment/android)
- [Google Play Console ヘルプ](https://support.google.com/googleplay/android-developer)
- [Android アプリの署名](https://developer.android.com/studio/publish/app-signing)

## 🎯 次のステップ

リリース版の作成が完了したら、以下のことを検討してください：

1. **継続的インテグレーション（CI/CD）**の設定
2. **自動テスト**の実装
3. **アナリティクス**の追加
4. **ユーザーフィードバック**の収集システム
5. **A/Bテスト**の実施

---

**注意**: このガイドは一般的な手順です。実際のリリース時には、Google Play Consoleの最新の要件とポリシーを確認してください。
