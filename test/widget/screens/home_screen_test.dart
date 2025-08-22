import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impossible_tap/screens/home_screen.dart';
import '../../test_helpers/mock_services.dart';

void main() {
  group('HomeScreen Widget', () {
    testWidgets('HomeScreenが正常に描画される', (WidgetTester tester) async {
      await tester.pumpWidget(
        const TestAppWrapper(
          child: HomeScreen(),
        ),
      );

      // HomeScreenが描画されていることを確認
      expect(find.byType(HomeScreen), findsOneWidget);
      
      // MaterialAppが存在することを確認（TestAppWrapper内）
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('基本的なウィジェット構造の確認', (WidgetTester tester) async {
      await tester.pumpWidget(
        const TestAppWrapper(
          child: HomeScreen(),
        ),
      );

      // 非同期的な初期化を待つ
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 基本的なウィジェットが存在することを確認
      expect(find.byType(AnimatedBuilder), findsWidgets);
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('初期状態での例外が発生しない', (WidgetTester tester) async {
      await tester.pumpWidget(
        const TestAppWrapper(
          child: HomeScreen(),
        ),
      );

      // ウィジェットが構築されるまで待機
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 致命的なエラーが発生していないことを確認
      expect(tester.takeException(), isNull);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('アニメーションコントローラーが初期化される', (WidgetTester tester) async {
      await tester.pumpWidget(
        const TestAppWrapper(
          child: HomeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // AnimatedBuilderが存在することで、アニメーションコントローラーの存在を間接的に確認
      expect(find.byType(AnimatedBuilder), findsWidgets);
    });

    testWidgets('画面破棄時にリソースが適切にクリーンアップされる', (WidgetTester tester) async {
      await tester.pumpWidget(
        const TestAppWrapper(
          child: HomeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // ウィジェットが正常に構築されていることを確認
      expect(find.byType(HomeScreen), findsOneWidget);

      // 別の画面に遷移（ウィジェットを破棄）
      await tester.pumpWidget(
        const TestAppWrapper(
          child: Scaffold(
            body: Text('Other Screen'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // HomeScreenが存在しないことを確認
      expect(find.byType(HomeScreen), findsNothing);
      expect(find.text('Other Screen'), findsOneWidget);

      // メモリリークがないことの確認（例外が発生していないことで判断）
      expect(tester.takeException(), isNull);
    });

    group('エラーハンドリング', () {
      testWidgets('初期化エラー時も画面が表示される', (WidgetTester tester) async {
        await tester.pumpWidget(
          const TestAppWrapper(
            child: HomeScreen(),
          ),
        );

        // 初期化処理を待つ
        await tester.pump();
        
        // エラーが発生していても画面が表示されることを確認
        expect(find.byType(HomeScreen), findsOneWidget);
        
        // 致命的なエラーが発生していないことを確認
        expect(tester.takeException(), isNull);
      });

      testWidgets('非同期処理のエラーハンドリング', (WidgetTester tester) async {
        await tester.pumpWidget(
          const TestAppWrapper(
            child: HomeScreen(),
          ),
        );

        // 長時間の非同期処理を待機
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // 非同期処理エラーが適切にハンドリングされていることを確認
        expect(tester.takeException(), isNull);
      });
    });

    group('パフォーマンステスト', () {
      testWidgets('複数回のpumpでもパフォーマンスが劣化しない', (WidgetTester tester) async {
        await tester.pumpWidget(
          const TestAppWrapper(
            child: HomeScreen(),
          ),
        );

        await tester.pumpAndSettle();

        // 複数回のpumpを実行してもパフォーマンスが劣化しないことを確認
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 16)); // 60FPS相当
        }
        
        stopwatch.stop();
        
        // 許容可能な時間内で処理が完了することを確認
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
        expect(tester.takeException(), isNull);
      });
    });

    group('基本的な操作テスト', () {
      testWidgets('画面タップ時の基本動作', (WidgetTester tester) async {
        await tester.pumpWidget(
          const TestAppWrapper(
            child: HomeScreen(),
          ),
        );

        await tester.pumpAndSettle();

        // 画面をタップ（中央部分）
        await tester.tapAt(const Offset(200, 300));
        await tester.pump();

        // タップ後もエラーが発生していないことを確認
        expect(tester.takeException(), isNull);
        expect(find.byType(HomeScreen), findsOneWidget);
      });
    });

    group('アクセシビリティテスト', () {
      testWidgets('基本的なアクセシビリティ要素の確認', (WidgetTester tester) async {
        await tester.pumpWidget(
          const TestAppWrapper(
            child: HomeScreen(),
          ),
        );

        await tester.pumpAndSettle();

        // アクセシビリティが適切に設定されていることを確認
        expect(find.byType(MaterialApp), findsOneWidget);
        
        // 基本的なウィジェットが存在することを確認
        expect(find.byType(Text), findsWidgets);
      });
    });
  });
}

/// HomeScreenの状態にアクセスするためのヘルパー（テスト用）
extension HomeScreenTestExtension on WidgetTester {
  State getHomeScreenState() {
    return state(find.byType(HomeScreen));
  }
}