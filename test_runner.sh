#!/bin/bash

# MURITAPアプリケーション - 自動テスト実行スクリプト
# 
# このスクリプトは以下のテストを順番に実行します：
# 1. 依存関係の確認とインストール
# 2. コード解析（flutter analyze）
# 3. 単体テスト実行
# 4. ウィジェットテスト実行
# 5. 統合テスト実行
# 6. テストカバレッジレポート生成

set -e  # エラー時に停止

# カラー出力用の定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ログ関数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# テスト実行ディレクトリに移動
cd "$(dirname "$0")"

log_info "MURITAP アプリケーションテスト実行を開始します..."

# 1. 依存関係の確認とインストール
log_info "依存関係をインストール中..."
if flutter pub get; then
    log_success "依存関係のインストールが完了しました"
else
    log_error "依存関係のインストールに失敗しました"
    exit 1
fi

# モックファイル生成
log_info "モックファイルを生成中..."
if dart run build_runner build --delete-conflicting-outputs; then
    log_success "モックファイルの生成が完了しました"
else
    log_warning "モックファイルの生成をスキップします（必要なファイルがない可能性があります）"
fi

# 2. コード解析
log_info "コード解析を実行中..."
if flutter analyze; then
    log_success "コード解析が正常に完了しました"
else
    log_error "コード解析でエラーが検出されました"
    exit 1
fi

# 3. 単体テスト実行
log_info "単体テストを実行中..."
if flutter test test/unit/ --reporter expanded; then
    log_success "単体テストが正常に完了しました"
else
    log_error "単体テストで失敗があります"
    exit 1
fi

# 4. ウィジェットテスト実行
log_info "ウィジェットテストを実行中..."
if flutter test test/widget/ --reporter expanded; then
    log_success "ウィジェットテストが正常に完了しました"
else
    log_error "ウィジェットテストで失敗があります"
    exit 1
fi

# 5. 全テスト実行（カバレッジ付き）
log_info "全テスト（カバレッジ付き）を実行中..."
if flutter test --coverage --reporter expanded; then
    log_success "全テストが正常に完了しました"
else
    log_error "テストで失敗があります"
    exit 1
fi

# 6. 統合テスト実行（オプション）
read -p "統合テストを実行しますか？ (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "統合テストを実行中..."
    
    # デバイスの確認
    if flutter devices | grep -q "flutter test"; then
        if flutter test integration_test/; then
            log_success "統合テストが正常に完了しました"
        else
            log_error "統合テストで失敗があります"
            exit 1
        fi
    else
        log_warning "利用可能なデバイスがないため統合テストをスキップします"
    fi
else
    log_info "統合テストをスキップしました"
fi

# 7. カバレッジレポート生成（lcovがインストールされている場合）
if command -v lcov &> /dev/null; then
    log_info "カバレッジレポートを生成中..."
    
    # lcovファイルからHTMLレポートを生成
    if genhtml coverage/lcov.info -o coverage/html; then
        log_success "カバレッジレポートが生成されました: coverage/html/index.html"
        
        # macOSの場合、自動でブラウザでレポートを開く
        if [[ "$OSTYPE" == "darwin"* ]]; then
            read -p "カバレッジレポートをブラウザで開きますか？ (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                open coverage/html/index.html
            fi
        fi
    else
        log_warning "カバレッジレポートの生成に失敗しました"
    fi
else
    log_warning "lcovがインストールされていないため、カバレッジレポート生成をスキップします"
    log_info "インストール方法: brew install lcov (macOS) または apt-get install lcov (Ubuntu)"
fi

# 8. テスト結果サマリー
log_info "==============================="
log_info "テスト実行結果サマリー"
log_info "==============================="
log_success "✅ コード解析: 合格"
log_success "✅ 単体テスト: 合格"
log_success "✅ ウィジェットテスト: 合格"
log_success "✅ 全テスト: 合格"

if [[ $REPLY =~ ^[Yy]$ ]] && flutter devices | grep -q "flutter test"; then
    log_success "✅ 統合テスト: 合格"
else
    log_info "ℹ️  統合テスト: スキップ"
fi

log_info "==============================="
log_success "🎉 全てのテストが正常に完了しました！"
log_info "カバレッジファイル: coverage/lcov.info"

if [ -d "coverage/html" ]; then
    log_info "カバレッジレポート: coverage/html/index.html"
fi

log_info "==============================="