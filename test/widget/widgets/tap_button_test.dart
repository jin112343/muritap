import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impossible_tap/widgets/tap_button.dart';
import '../../test_helpers/mock_services.dart';

void main() {
  group('TapButton Widget', () {
    late AnimationController animationController;
    bool tapCallbackInvoked = false;
    
    setUp(() {
      tapCallbackInvoked = false;
    });

    testWidgets('ウィジェットが正しく描画される', (WidgetTester tester) async {
      // AnimationControllerのセットアップ
      animationController = AnimationController(
        duration: const Duration(milliseconds: 100),
        vsync: tester,
      );
      addTearDown(() => animationController.dispose());

      await tester.pumpWidget(
        TestAppWrapper(
          child: TapButton(
            onTap: () => tapCallbackInvoked = true,
            animationController: animationController,
          ),
        ),
      );

      // TapButtonが描画されているか確認
      expect(find.byType(TapButton), findsOneWidget);
      expect(find.byType(GestureDetector), findsWidgets);
      expect(find.byType(AnimatedBuilder), findsWidgets);
    });

    testWidgets('タップ時にコールバックが呼ばれる', (WidgetTester tester) async {
      animationController = AnimationController(
        duration: const Duration(milliseconds: 100),
        vsync: tester,
      );
      addTearDown(() => animationController.dispose());

      await tester.pumpWidget(
        TestAppWrapper(
          child: TapButton(
            onTap: () => tapCallbackInvoked = true,
            animationController: animationController,
          ),
        ),
      );

      // タップ前はコールバックが呼ばれていない
      expect(tapCallbackInvoked, isFalse);

      // ウィジェットをタップ
      await tester.tap(find.byType(TapButton));
      await tester.pump();

      // コールバックが呼ばれたことを確認
      expect(tapCallbackInvoked, isTrue);
    });

    testWidgets('処理中フラグがtrueの時はタップが無効化される', (WidgetTester tester) async {
      animationController = AnimationController(
        duration: const Duration(milliseconds: 100),
        vsync: tester,
      );
      addTearDown(() => animationController.dispose());

      await tester.pumpWidget(
        TestAppWrapper(
          child: TapButton(
            onTap: () => tapCallbackInvoked = true,
            animationController: animationController,
            isProcessing: true, // 処理中フラグをtrueに設定
          ),
        ),
      );

      // タップ前はコールバックが呼ばれていない
      expect(tapCallbackInvoked, isFalse);

      // ウィジェットをタップ
      await tester.tap(find.byType(TapButton));
      await tester.pump();

      // 処理中なので、コールバックが呼ばれていないことを確認
      expect(tapCallbackInvoked, isFalse);
    });

    testWidgets('アニメーションが正しく動作する', (WidgetTester tester) async {
      animationController = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: tester,
      );
      addTearDown(() => animationController.dispose());

      await tester.pumpWidget(
        TestAppWrapper(
          child: TapButton(
            onTap: () => tapCallbackInvoked = true,
            animationController: animationController,
          ),
        ),
      );

      // アニメーションコントローラーが存在することを確認
      expect(find.byType(Transform), findsWidgets);

      // アニメーションを開始
      animationController.forward();
      await tester.pump(const Duration(milliseconds: 250)); // 中間地点
      await tester.pump(const Duration(milliseconds: 250)); // 完了まで待つ

      // アニメーション後もTransformが存在することを確認
      expect(find.byType(Transform), findsWidgets);
      
      // アニメーションを停止
      animationController.stop();
    });

    testWidgets('ボタンの外観が正しく描画される', (WidgetTester tester) async {
      animationController = AnimationController(
        duration: const Duration(milliseconds: 100),
        vsync: tester,
      );
      addTearDown(() => animationController.dispose());

      await tester.pumpWidget(
        TestAppWrapper(
          child: TapButton(
            onTap: () {},
            animationController: animationController,
          ),
        ),
      );

      // Containerが複数描画されていることを確認（ベース層、中間層、表面層）
      expect(find.byType(Container), findsWidgets);

      // Stackが使用されていることを確認（重ね合わせのため）
      expect(find.byType(Stack), findsWidgets);

      // 基本的なウィジェットが存在することを確認
      expect(find.byType(TapButton), findsOneWidget);
    });

    testWidgets('複数回タップできることを確認', (WidgetTester tester) async {
      int tapCount = 0;
      animationController = AnimationController(
        duration: const Duration(milliseconds: 100),
        vsync: tester,
      );
      addTearDown(() => animationController.dispose());

      await tester.pumpWidget(
        TestAppWrapper(
          child: TapButton(
            onTap: () => tapCount++,
            animationController: animationController,
          ),
        ),
      );

      // 初期状態
      expect(tapCount, equals(0));

      // 3回タップ
      await tester.tap(find.byType(TapButton));
      await tester.pump();
      expect(tapCount, equals(1));

      await tester.tap(find.byType(TapButton));
      await tester.pump();
      expect(tapCount, equals(2));

      await tester.tap(find.byType(TapButton));
      await tester.pump();
      expect(tapCount, equals(3));
    });

    testWidgets('高速タップでも正しく動作する', (WidgetTester tester) async {
      int rapidTapCount = 0;
      animationController = AnimationController(
        duration: const Duration(milliseconds: 50),
        vsync: tester,
      );
      addTearDown(() => animationController.dispose());

      await tester.pumpWidget(
        TestAppWrapper(
          child: TapButton(
            onTap: () => rapidTapCount++,
            animationController: animationController,
          ),
        ),
      );

      // 短時間で連続タップ
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.byType(TapButton));
        await tester.pump(const Duration(milliseconds: 10));
      }

      expect(rapidTapCount, equals(10));
    });

    testWidgets('処理中フラグの状態変更が正しく反映される', (WidgetTester tester) async {
      int tapCount = 0;
      bool isProcessing = false;
      animationController = AnimationController(
        duration: const Duration(milliseconds: 100),
        vsync: tester,
      );
      addTearDown(() => animationController.dispose());

      // 最初は処理中でない状態でウィジェットを構築
      await tester.pumpWidget(
        TestAppWrapper(
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  TapButton(
                    onTap: () => tapCount++,
                    animationController: animationController,
                    isProcessing: isProcessing,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isProcessing = !isProcessing;
                      });
                    },
                    child: const Text('Toggle Processing'),
                  ),
                ],
              );
            },
          ),
        ),
      );

      // 通常時はタップが有効
      await tester.tap(find.byType(TapButton));
      await tester.pump();
      expect(tapCount, equals(1));

      // 処理中フラグをtrueに変更
      await tester.tap(find.text('Toggle Processing'));
      await tester.pump();

      // 処理中はタップが無効
      await tester.tap(find.byType(TapButton));
      await tester.pump();
      expect(tapCount, equals(1)); // カウントが増えない

      // 処理中フラグをfalseに戻す
      await tester.tap(find.text('Toggle Processing'));
      await tester.pump();

      // 再びタップが有効になる
      await tester.tap(find.byType(TapButton));
      await tester.pump();
      expect(tapCount, equals(2));
    });

    // addTearDownを各テスト内で使用
  });
}