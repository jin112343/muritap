#!/bin/bash

# Androidリリース版をビルドするスクリプト

echo "🚀 Androidリリース版のビルドを開始します..."
echo ""

# 現在のディレクトリを確認
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ エラー: Flutterプロジェクトのルートディレクトリで実行してください。"
    exit 1
fi

# Flutterの状態を確認
echo "📱 Flutterの状態を確認中..."
flutter doctor

if [ $? -ne 0 ]; then
    echo "❌ Flutterの設定に問題があります。flutter doctorを確認してください。"
    exit 1
fi

# 依存関係を更新
echo ""
echo "📦 依存関係を更新中..."
flutter pub get

# クリーンビルド
echo ""
echo "🧹 クリーンビルドを実行中..."
flutter clean
flutter pub get

# リリース版をビルド
echo ""
echo "🔨 Androidリリース版をビルド中..."
flutter build apk --release

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ リリース版のビルドが完了しました！"
    echo ""
    echo "📱 APKファイルの場所:"
    echo "   build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    echo "📊 APKファイルのサイズ:"
    ls -lh build/app/outputs/flutter-apk/app-release.apk
    
    echo ""
    echo "🎯 次の手順:"
    echo "1. APKファイルをテストデバイスでインストールして動作確認"
    echo "2. Google Play Consoleにアプリをアップロード"
    echo "3. 必要に応じてGoogle Play App Signingを設定"
    
    # APKファイルを開く
    if command -v open >/dev/null 2>&1; then
        echo ""
        read -p "APKファイルの場所を開きますか？ (y/N): " open_apk
        if [[ $open_apk == [yY] ]]; then
            open build/app/outputs/flutter-apk/
        fi
    fi
else
    echo ""
    echo "❌ ビルドに失敗しました。エラーメッセージを確認してください。"
    exit 1
fi
