# Play Games Services セットアップガイド

このドキュメントでは、AndroidアプリにGoogle Play Games Servicesを設定する手順を説明します。

## 前提条件

- Google Play Console アカウント
- アプリが Google Play Console に登録されていること

## セットアップ手順

### 1. Google Play Console でゲームを設定

1. [Google Play Console](https://play.google.com/console) にアクセス
2. アプリを選択
3. 左側のメニューから「成長」→「Play Games Services」→「設定と管理」→「設定」を選択
4. 「新しいゲームを作成」をクリック
5. ゲーム名を入力（例: MURITAP）
6. カテゴリを選択
7. 「作成」をクリック

### 2. OAuth 2.0 クライアント ID を作成

1. Play Games Services 設定画面で「認証情報」タブを選択
2. 「OAuth クライアントを作成」をクリック
3. 「Android」を選択
4. 以下の情報を入力:
   - **名前**: アプリ名（例: MURITAP Android）
   - **パッケージ名**: `com.mizoishun.impossible_tap`
   - **SHA-1 証明書フィンガープリント**: 以下のコマンドで取得
     ```bash
     # デバッグ用
     keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

     # リリース用
     keytool -list -v -keystore android/app/keystore.jks -alias jinjin4423 -storepass jinjin4423 -keypass jinjin4423
     ```
5. 「作成」をクリック

### 3. リーダーボードを作成

1. 左側のメニューから「リーダーボード」を選択
2. 「リーダーボードを作成」をクリック
3. 以下の情報を入力:
   - **名前**: 総タップ数ランキング
   - **説明**: MURITAPの総タップ数ランキング
   - **アイコン**: アプリのアイコン
   - **スコアの種類**: 大きいほど良い
   - **スコアの順序**: 降順
   - **表示形式**: 数値
4. 「保存」をクリック
5. 作成されたリーダーボードの **ID** をコピー（例: `CgkIuZH_2fgOEAIQAQ`）

### 4. プロジェクト ID を取得

1. Play Games Services 設定画面の上部に表示されている **プロジェクト ID** をコピー

### 5. アプリに設定を反映

#### 5.1 strings.xml を更新

`android/app/src/main/res/values/strings.xml` を開き、以下を更新:

```xml
<string name="game_services_project_id">YOUR_GAME_PROJECT_ID</string>
```

`YOUR_GAME_PROJECT_ID` を手順4で取得したプロジェクトIDに置き換えます。

#### 5.2 app_config.dart を更新

`lib/config/app_config.dart` を開き、以下を更新:

```dart
static const String playGamesLeaderboardId = 'CgkIuZH_2fgOEAIQAQ';
```

`CgkIuZH_2fgOEAIQAQ` を手順3で取得したリーダーボードIDに置き換えます。

### 6. テスト

1. Google Play Console で「テスター」を追加
2. テストアカウントでアプリにサインイン
3. ランキング機能をテスト

## トラブルシューティング

### サインインできない

- SHA-1 証明書フィンガープリントが正しいか確認
- OAuth クライアント ID が正しく設定されているか確認
- テストアカウントが追加されているか確認

### リーダーボードが表示されない

- リーダーボード ID が正しいか確認
- プロジェクト ID が正しいか確認
- アプリが公開されている、またはテスターとして追加されているか確認

## 参考リンク

- [Play Games Services v2 SDK ガイド](https://developers.google.com/games/services/android/quickstart)
- [Google Play Console](https://play.google.com/console)
