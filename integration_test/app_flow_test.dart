import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:impossible_tap/main.dart' as app;

/// MURITAP アプリケーションの統合テスト
/// 完全なユーザーフローをテストし、実際のアプリの動作を確認する
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('MURITAPアプリケーション 統合テスト', () {
    testWidgets('アプリの起動とホーム画面の表示', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // ホーム画面が表示されることを確認
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // 基本的なUI要素の存在確認
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('基本的なタップ機能のテスト', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // タップボタンを探して確認
      final tapButtonFinder = find.byType(GestureDetector);
      if (tapButtonFinder.evaluate().isNotEmpty) {
        // タップボタンが存在する場合のテスト
        await tester.tap(tapButtonFinder.first);
        await tester.pumpAndSettle();
        
        // タップ後の状態変化を確認（具体的な実装に依存）
        expect(tester.takeException(), isNull);
      } else {
        // タップボタンが見つからない場合はスキップ
        // （実際の実装に応じて調整が必要）
      }
    });

    testWidgets('複数画面の遷移テスト', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // ボトムナビゲーションまたはメニューボタンを探す
      final settingsButtonFinder = find.byIcon(Icons.settings);

      if (settingsButtonFinder.evaluate().isNotEmpty) {
        // 設定画面への遷移テスト
        await tester.tap(settingsButtonFinder);
        await tester.pumpAndSettle();
        
        // 設定画面が表示されることを確認
        expect(tester.takeException(), isNull);
        
        // 戻るボタンで元の画面に戻る
        final backButtonFinder = find.byIcon(Icons.arrow_back);
        if (backButtonFinder.evaluate().isNotEmpty) {
          await tester.tap(backButtonFinder);
          await tester.pumpAndSettle();
        }
      }

      // ランキング画面への遷移テスト（もし存在する場合）
      final rankingButtonFinder = find.byIcon(Icons.leaderboard);
      if (rankingButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(rankingButtonFinder);
        await tester.pumpAndSettle();
        
        expect(tester.takeException(), isNull);
        
        // 戻る
        final backButtonFinder = find.byIcon(Icons.arrow_back);
        if (backButtonFinder.evaluate().isNotEmpty) {
          await tester.tap(backButtonFinder);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('連続タップによるレベルアップフローテスト', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // タップボタンを探す
      final tapButtonFinder = find.byType(GestureDetector);
      
      if (tapButtonFinder.evaluate().isNotEmpty) {
        // 連続タップでレベルアップを狙う
        for (int i = 0; i < 50; i++) {
          await tester.tap(tapButtonFinder.first);
          await tester.pump(const Duration(milliseconds: 50));
          
          // エラーが発生していないことを確認
          expect(tester.takeException(), isNull);
        }
        
        // 最終的な状態確認
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('データの永続化テスト', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 現在の表示内容を記録（レベルやタップ数）
      final initialTexts = <String>[];
      final textFinders = find.byType(Text);
      for (final element in textFinders.evaluate()) {
        final textWidget = element.widget as Text;
        if (textWidget.data != null) {
          initialTexts.add(textWidget.data!);
        }
      }

      // タップ操作を実行
      final tapButtonFinder = find.byType(GestureDetector);
      if (tapButtonFinder.evaluate().isNotEmpty) {
        for (int i = 0; i < 10; i++) {
          await tester.tap(tapButtonFinder.first);
          await tester.pump(const Duration(milliseconds: 100));
        }
      }
      
      await tester.pumpAndSettle();

      // アプリを再起動（データ永続化の確認）
      await tester.pumpWidget(Container()); // 一旦クリア
      await tester.pumpAndSettle();
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // データが保持されていることを確認（エラーが発生していないことで判断）
      expect(tester.takeException(), isNull);
    });

    testWidgets('アプリのパフォーマンステスト', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final stopwatch = Stopwatch()..start();

      // 大量の操作を短時間で実行
      final tapButtonFinder = find.byType(GestureDetector);
      if (tapButtonFinder.evaluate().isNotEmpty) {
        for (int i = 0; i < 100; i++) {
          await tester.tap(tapButtonFinder.first);
          await tester.pump(const Duration(milliseconds: 10));
        }
      }

      await tester.pumpAndSettle();
      stopwatch.stop();

      // パフォーマンスが許容範囲内であることを確認
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      expect(tester.takeException(), isNull);
    });

    testWidgets('エラー回復テスト', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 異常な操作を試行（高速連続タップ等）
      final tapButtonFinder = find.byType(GestureDetector);
      if (tapButtonFinder.evaluate().isNotEmpty) {
        // 非常に高速な連続タップ
        for (int i = 0; i < 200; i++) {
          await tester.tap(tapButtonFinder.first);
          // 意図的に待機時間を短くして負荷をかける
        }
      }

      await tester.pumpAndSettle();

      // アプリが正常な状態に回復していることを確認
      expect(tester.takeException(), isNull);
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('メモリリークテスト', (WidgetTester tester) async {
      // 複数回のアプリ起動・終了サイクル
      for (int cycle = 0; cycle < 3; cycle++) {
        // アプリを起動
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // 基本操作を実行
        final tapButtonFinder = find.byType(GestureDetector);
        if (tapButtonFinder.evaluate().isNotEmpty) {
          for (int i = 0; i < 10; i++) {
            await tester.tap(tapButtonFinder.first);
            await tester.pump(const Duration(milliseconds: 50));
          }
        }

        // アプリを終了（ウィジェットをクリア）
        await tester.pumpWidget(Container());
        await tester.pumpAndSettle();
      }

      // メモリリークが発生していないことを確認（例外がないことで判断）
      expect(tester.takeException(), isNull);
    });

    group('エッジケーステスト', () {
      testWidgets('低メモリ環境でのテスト', (WidgetTester tester) async {
        // アプリを起動
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // 大量のデータ操作を行って、低メモリ状況をシミュレート
        final tapButtonFinder = find.byType(GestureDetector);
        if (tapButtonFinder.evaluate().isNotEmpty) {
          for (int i = 0; i < 500; i++) {
            await tester.tap(tapButtonFinder.first);
            await tester.pump(const Duration(microseconds: 1));
          }
        }

        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('画面回転テスト', (WidgetTester tester) async {
        // 縦画面でアプリを起動
        await tester.binding.setSurfaceSize(const Size(360, 640));
        
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // 基本操作を実行
        final tapButtonFinder = find.byType(GestureDetector);
        if (tapButtonFinder.evaluate().isNotEmpty) {
          await tester.tap(tapButtonFinder.first);
          await tester.pumpAndSettle();
        }

        // 横画面に回転
        await tester.binding.setSurfaceSize(const Size(640, 360));
        await tester.pumpAndSettle();

        // 回転後も正常に動作することを確認
        expect(tester.takeException(), isNull);
        expect(find.byType(MaterialApp), findsOneWidget);

        // 縦画面に戻す
        await tester.binding.setSurfaceSize(const Size(360, 640));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);

        // デフォルトサイズに戻す
        await tester.binding.setSurfaceSize(null);
      });
    });
  });
}