import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impossible_tap/services/title_service.dart';
import '../../test_helpers/mock_services.dart';

void main() {
  group('TitleService', () {
    late TitleService titleService;

    setUp(() {
      titleService = TitleService.instance;
    });

    group('シングルトンパターン', () {
      test('インスタンスが正しくシングルトンとして動作する', () {
        final instance1 = TitleService.instance;
        final instance2 = TitleService.instance;
        
        expect(instance1, same(instance2));
      });
    });

    group('レベル別称号', () {
      testWidgets('各レベルの称号が取得できる', (WidgetTester tester) async {
        await tester.pumpWidget(
          const TestAppWrapper(
            child: TitleTestWidget(),
          ),
        );

        final BuildContext context = tester.element(find.byType(TitleTestWidget));
        
        // レベル1の称号
        final title1 = titleService.getTitle(1, context);
        expect(title1, isNotEmpty);
        expect(title1, isA<String>());

        // レベル5の称号
        final title5 = titleService.getTitle(5, context);
        expect(title5, isNotEmpty);

        // レベル10の称号
        final title10 = titleService.getTitle(10, context);
        expect(title10, isNotEmpty);

        // レベル20の称号
        final title20 = titleService.getTitle(20, context);
        expect(title20, isNotEmpty);

        // レベル50の称号
        final title50 = titleService.getTitle(50, context);
        expect(title50, isNotEmpty);

        // レベル100の称号
        final title100 = titleService.getTitle(100, context);
        expect(title100, isNotEmpty);

        // レベル200の称号
        final title200 = titleService.getTitle(200, context);
        expect(title200, isNotEmpty);

        // レベル500の称号
        final title500 = titleService.getTitle(500, context);
        expect(title500, isNotEmpty);

        // レベル1000の称号
        final title1000 = titleService.getTitle(1000, context);
        expect(title1000, isNotEmpty);
      });

      testWidgets('称号の階層性テスト', (WidgetTester tester) async {
        await tester.pumpWidget(
          const TestAppWrapper(
            child: TitleTestWidget(),
          ),
        );

        final BuildContext context = tester.element(find.byType(TitleTestWidget));
        
        final title1 = titleService.getTitle(1, context);
        final title50 = titleService.getTitle(50, context);
        final title1000 = titleService.getTitle(1000, context);
        
        // 異なる称号が返されることを確認
        expect(title1, isNot(equals(title1000)));
        expect(title50, isNot(equals(title1000)));

        // 境界値での称号変化
        final title4 = titleService.getTitle(4, context);
        final title5 = titleService.getTitle(5, context);
        final title9 = titleService.getTitle(9, context);
        final title10 = titleService.getTitle(10, context);
        
        expect(title4, isNot(equals(title5)));
        expect(title9, isNot(equals(title10)));
      });
    });

    group('称号色の取得', () {
      test('各レベルの色が正しい', () {
        expect(titleService.getTitleColor(1), equals(Colors.grey));
        expect(titleService.getTitleColor(5), equals(Colors.teal));
        expect(titleService.getTitleColor(10), equals(Colors.cyan));
        expect(titleService.getTitleColor(20), equals(Colors.blue));
        expect(titleService.getTitleColor(50), equals(Colors.green));
        expect(titleService.getTitleColor(100), equals(Colors.yellow));
        expect(titleService.getTitleColor(200), equals(Colors.orange));
        expect(titleService.getTitleColor(500), equals(Colors.red));
        expect(titleService.getTitleColor(1000), equals(Colors.purple));
      });
    });

    group('称号アイコンの取得', () {
      test('各レベルのアイコンが取得できる', () {
        expect(titleService.getTitleIcon(1), isA<IconData>());
        expect(titleService.getTitleIcon(5), isA<IconData>());
        expect(titleService.getTitleIcon(100), equals(Icons.workspace_premium));
        expect(titleService.getTitleIcon(200), equals(Icons.diamond));
        expect(titleService.getTitleIcon(500), equals(Icons.star));
        expect(titleService.getTitleIcon(1000), equals(Icons.auto_awesome));
      });
    });

    group('カスタム称号のテスト', () {
      testWidgets('カスタム称号が優先される', (WidgetTester tester) async {
        await tester.pumpWidget(
          const TestAppWrapper(
            child: TitleTestWidget(),
          ),
        );

        final BuildContext context = tester.element(find.byType(TitleTestWidget));

        final customTitle = titleService.getTitle(
          1000,
          context,
          titleGod: 'カスタム神',
        );
        
        expect(customTitle, equals('カスタム神'));
      });

      testWidgets('部分的なカスタム称号', (WidgetTester tester) async {
        await tester.pumpWidget(
          const TestAppWrapper(
            child: TitleTestWidget(),
          ),
        );

        final BuildContext context = tester.element(find.byType(TitleTestWidget));

        final customMaster = titleService.getTitle(
          200,
          context,
          titleMaster: 'カスタムマスター',
        );
        
        expect(customMaster, equals('カスタムマスター'));
        
        // 他の称号はデフォルトのまま
        final defaultGod = titleService.getTitle(1000, context);
        expect(defaultGod, isNot(equals('カスタムマスター')));
      });
    });

    group('極端なレベル値のテスト', () {
      testWidgets('非常に高いレベル', (WidgetTester tester) async {
        await tester.pumpWidget(
          const TestAppWrapper(
            child: TitleTestWidget(),
          ),
        );

        final BuildContext context = tester.element(find.byType(TitleTestWidget));

        final title = titleService.getTitle(999999, context);
        expect(title, isNotEmpty);
        
        final color = titleService.getTitleColor(999999);
        expect(color, equals(Colors.purple));
        
        final icon = titleService.getTitleIcon(999999);
        expect(icon, equals(Icons.auto_awesome));
      });

      testWidgets('ゼロレベル', (WidgetTester tester) async {
        await tester.pumpWidget(
          const TestAppWrapper(
            child: TitleTestWidget(),
          ),
        );

        final BuildContext context = tester.element(find.byType(TitleTestWidget));

        final title = titleService.getTitle(0, context);
        expect(title, isNotEmpty);
        
        final color = titleService.getTitleColor(0);
        expect(color, equals(Colors.grey));
      });
    });
  });
}

/// テスト用のダミーウィジェット
class TitleTestWidget extends StatelessWidget {
  const TitleTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}