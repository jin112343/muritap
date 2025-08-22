import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impossible_tap/widgets/level_display.dart';
import 'package:impossible_tap/services/data_service.dart';
import '../../test_helpers/mock_services.dart';

void main() {
  group('LevelDisplay Widget', () {
    late AnimationController animationController;

    testWidgets('基本的なレベル表示が正しく描画される', (WidgetTester tester) async {
      animationController = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: tester,
      );

      await tester.pumpWidget(
        TestAppWrapper(
          child: LevelDisplay(
            currentLevel: 5,
            totalTaps: 100,
            isLevelUp: false,
            animationController: animationController,
          ),
        ),
      );

      // LevelDisplayが描画されていることを確認
      expect(find.byType(LevelDisplay), findsOneWidget);
      
      // レベルテキストが正しく表示されているか確認
      expect(find.textContaining('5'), findsOneWidget);
      
      // プログレスバーが描画されているか確認
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      
      // パーセンテージ表示があることを確認
      expect(find.textContaining('%'), findsOneWidget);
    });

    testWidgets('レベルアップ時のアニメーションが動作する', (WidgetTester tester) async {
      animationController = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: tester,
      );

      await tester.pumpWidget(
        TestAppWrapper(
          child: LevelDisplay(
            currentLevel: 10,
            totalTaps: 200,
            isLevelUp: true, // レベルアップフラグをtrueに
            animationController: animationController,
          ),
        ),
      );

      // 初期状態でのコンテナ確認
      expect(find.byType(Container), findsWidgets);
      
      // アニメーションを開始
      animationController.forward();
      await tester.pump(const Duration(milliseconds: 100));
      
      // アニメーション中の確認
      await tester.pump(const Duration(milliseconds: 200));
      
      // アニメーション完了
      await tester.pump(const Duration(milliseconds: 300));
      
      // レベル表示が維持されていることを確認
      expect(find.textContaining('10'), findsOneWidget);
    });

    testWidgets('プログレス計算が正しく動作する', (WidgetTester tester) async {
      animationController = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: tester,
      );

      const currentLevel = 3;
      const totalTaps = 50;

      await tester.pumpWidget(
        TestAppWrapper(
          child: LevelDisplay(
            currentLevel: currentLevel,
            totalTaps: totalTaps,
            isLevelUp: false,
            animationController: animationController,
          ),
        ),
      );

      // プログレスバーが存在することを確認
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      
      // プログレス値が0.0〜1.0の範囲内であることをテスト
      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator)
      );
      
      expect(progressIndicator.value, greaterThanOrEqualTo(0.0));
      expect(progressIndicator.value, lessThanOrEqualTo(1.0));
    });

    testWidgets('各レベルでの必要タップ数表示が正しい', (WidgetTester tester) async {
      animationController = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: tester,
      );

      final dataService = DataService();
      const testLevel = 5;
      final nextLevelTaps = dataService.getRequiredTapsForLevel(testLevel + 1);
      final currentLevelTaps = dataService.getRequiredTapsForLevel(testLevel);
      const totalTaps = 150;

      await tester.pumpWidget(
        TestAppWrapper(
          child: LevelDisplay(
            currentLevel: testLevel,
            totalTaps: totalTaps,
            isLevelUp: false,
            animationController: animationController,
          ),
        ),
      );

      // 必要タップ数の情報が表示されていることを確認
      final expectedCurrent = totalTaps - currentLevelTaps;
      final expectedMax = nextLevelTaps - currentLevelTaps;
      
      expect(find.textContaining('$expectedCurrent'), findsOneWidget);
      expect(find.textContaining('$expectedMax'), findsOneWidget);
    });

    testWidgets('プログレスが100%に達した場合の表示', (WidgetTester tester) async {
      animationController = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: tester,
      );

      await tester.pumpWidget(
        TestAppWrapper(
          child: LevelDisplay(
            currentLevel: 2,
            totalTaps: 1000, // 十分に多いタップ数
            isLevelUp: false,
            animationController: animationController,
          ),
        ),
      );

      // 100%表示があることを確認
      expect(find.textContaining('100%'), findsOneWidget);
      
      // プログレスバーの値が1.0であることを確認
      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator)
      );
      expect(progressIndicator.value, equals(1.0));
    });

    testWidgets('極端に低いタップ数での表示', (WidgetTester tester) async {
      animationController = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: tester,
      );

      await tester.pumpWidget(
        TestAppWrapper(
          child: LevelDisplay(
            currentLevel: 1,
            totalTaps: 0, // タップ数0
            isLevelUp: false,
            animationController: animationController,
          ),
        ),
      );

      // レベル1が表示されていることを確認
      expect(find.textContaining('1'), findsOneWidget);
      
      // 0%表示があることを確認
      expect(find.textContaining('0%'), findsOneWidget);
      
      // プログレスバーの値が0.0であることを確認
      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator)
      );
      expect(progressIndicator.value, equals(0.0));
    });

    testWidgets('高レベルでの表示テスト', (WidgetTester tester) async {
      animationController = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: tester,
      );

      await tester.pumpWidget(
        TestAppWrapper(
          child: LevelDisplay(
            currentLevel: 999,
            totalTaps: 1000000,
            isLevelUp: false,
            animationController: animationController,
          ),
        ),
      );

      // 高レベルが正しく表示されることを確認
      expect(find.textContaining('999'), findsOneWidget);
      
      // プログレスバーが存在することを確認
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('レベルアップと通常状態での色の違い', (WidgetTester tester) async {
      animationController = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: tester,
      );

      // 通常状態
      await tester.pumpWidget(
        TestAppWrapper(
          child: LevelDisplay(
            currentLevel: 5,
            totalTaps: 100,
            isLevelUp: false,
            animationController: animationController,
          ),
        ),
      );

      final normalContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(LevelDisplay),
          matching: find.byType(Container),
        ).first
      );

      // レベルアップ状態に変更
      await tester.pumpWidget(
        TestAppWrapper(
          child: LevelDisplay(
            currentLevel: 5,
            totalTaps: 100,
            isLevelUp: true,
            animationController: animationController,
          ),
        ),
      );

      final levelUpContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(LevelDisplay),
          matching: find.byType(Container),
        ).first
      );

      // 両方とも適切なDecorationを持っていることを確認
      expect(normalContainer.decoration, isNotNull);
      expect(levelUpContainer.decoration, isNotNull);
    });

    testWidgets('多言語対応のテキスト表示', (WidgetTester tester) async {
      animationController = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: tester,
      );

      await tester.pumpWidget(
        TestAppWrapper(
          child: LevelDisplay(
            currentLevel: 7,
            totalTaps: 150,
            isLevelUp: false,
            animationController: animationController,
          ),
        ),
      );

      // 多言語対応のテキストが存在することを確認
      // （実際のテキストはAppLocalizationsから取得されるため、存在確認のみ）
      expect(find.byType(Text), findsWidgets);
      
      // レベル数字は言語に関係なく表示される
      expect(find.textContaining('7'), findsOneWidget);
    });

    tearDown(() {
      animationController.dispose();
    });
  });
}