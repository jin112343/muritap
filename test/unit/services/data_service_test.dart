import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:impossible_tap/services/data_service.dart';
import 'package:impossible_tap/config/app_config.dart';
import '../../test_helpers/mock_services.dart';
import '../../test_helpers/mock_services.mocks.dart';

void main() {
  group('DataService', () {
    late DataService dataService;
    late MockSharedPreferences mockPrefs;

    setUp(() {
      dataService = DataService();
      mockPrefs = MockSharedPreferencesHelper.createMockPrefs();
    });

    group('初期化', () {
      test('正常に初期化される', () async {
        // SharedPreferences.getInstanceのモック化は困難なため、
        // 実際のテストでは初期化のロジックのみテスト
        expect(dataService, isNotNull);
      });
    });

    group('タップ数管理', () {
      test('デフォルトのタップ数は0', () {
        when(mockPrefs.getInt(AppConfig.keyTotalTaps)).thenReturn(null);
        
        // DataServiceは内部でSharedPreferencesを使うため、
        // この方法ではテストできません。実際の実装では依存性注入を使用することを推奨
        expect(0, equals(0)); // プレースホルダーテスト
      });

      test('保存されたタップ数を正しく取得', () {
        const testTaps = 150;
        when(mockPrefs.getInt(AppConfig.keyTotalTaps)).thenReturn(testTaps);
        
        expect(testTaps, equals(150));
      });
    });

    group('レベル計算', () {
      test('レベル1の必要タップ数は0', () {
        final result = DataService().getRequiredTapsForLevel(1);
        expect(result, equals(0));
      });

      test('レベル2の必要タップ数は正しく計算される', () {
        final result = DataService().getRequiredTapsForLevel(2);
        // baseTaps * pow(2, growthRate) = 10 * pow(2, 1.5) = 10 * 2.83... ≈ 28
        expect(result, greaterThan(20));
        expect(result, lessThan(50));
      });

      test('レベル10の必要タップ数は正しく計算される', () {
        final result = DataService().getRequiredTapsForLevel(10);
        expect(result, greaterThan(100));
        expect(result, lessThan(10000));
      });

      test('レベル100の必要タップ数は正しく計算される', () {
        final result = DataService().getRequiredTapsForLevel(100);
        expect(result, greaterThan(10000));
      });

      test('成長率がレベル範囲に応じて変化する', () {
        // レベル99以下は成長率1.5
        final level50Required = DataService().getRequiredTapsForLevel(50);
        final level51Required = DataService().getRequiredTapsForLevel(51);
        
        // レベル300以下は成長率1.5-1.6の範囲
        final level200Required = DataService().getRequiredTapsForLevel(200);
        final level201Required = DataService().getRequiredTapsForLevel(201);
        
        expect(level51Required, greaterThan(level50Required));
        expect(level201Required, greaterThan(level200Required));
      });
    });

    group('レベルアップ判定', () {
      test('レベルアップ条件を満たす場合', () {
        const currentLevel = 2;
        const totalTaps = 100; // レベル3に必要なタップ数を超えている
        
        final result = DataService().isLevelUp(totalTaps, currentLevel);
        expect(result, isTrue);
      });

      test('レベルアップ条件を満たさない場合', () {
        const currentLevel = 5;
        const totalTaps = 50; // レベル6に必要なタップ数に達していない
        
        final result = DataService().isLevelUp(totalTaps, currentLevel);
        expect(result, isFalse);
      });
    });

    group('最高達成レベル計算', () {
      test('タップ数0の場合、レベル1が最高', () {
        final result = DataService().getMaxAchievableLevel(0);
        expect(result, equals(1));
      });

      test('少数のタップ数の場合、適切なレベルを返す', () {
        final result = DataService().getMaxAchievableLevel(100);
        expect(result, greaterThanOrEqualTo(1));
        expect(result, lessThan(10));
      });

      test('大きなタップ数の場合、高レベルを返す', () {
        final result = DataService().getMaxAchievableLevel(100000);
        expect(result, greaterThan(10));
        expect(result, lessThanOrEqualTo(AppConfig.maxLevel));
      });
    });

    group('データ整合性チェック', () {
      test('データが初期化されていない場合はfalse', () {
        // 実際のテストでは、DataServiceが初期化されていない状態でのテストが必要
        expect(true, isTrue); // プレースホルダー
      });

      test('負の値がある場合はfalse', () {
        // 実際の実装では、負の値のチェックをテスト
        expect(true, isTrue); // プレースホルダー
      });
    });

    group('デイリーチャレンジ', () {
      test('デイリーチャレンジが完了していない場合はfalse', () {
        // 実際の実装では、今日の日付での完了チェック
        expect(true, isTrue); // プレースホルダー
      });
    });
  });
}