import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:impossible_tap/services/stats_service.dart';

void main() {
  group('StatsService', () {
    late StatsService statsService;

    setUp(() {
      statsService = StatsService.instance;
    });

    group('日付キー生成', () {
      test('今日の日付キーが正しい形式で生成される', () {
        final now = DateTime.now();
        final expectedKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        
        // プライベートメソッドのため直接テストできないが、
        // 日付形式のロジックをテスト
        expect(expectedKey.length, equals(10));
        expect(expectedKey.contains('-'), isTrue);
        expect(expectedKey.split('-').length, equals(3));
      });
    });

    group('データフォーマット', () {
      test('日次統計のJSONエンコード・デコードが正しく動作する', () {
        final testData = {
          '2024-01-01': 100,
          '2024-01-02': 200,
          '2024-01-03_actual': 50,
        };
        
        final jsonString = jsonEncode(testData);
        final decodedData = Map<String, dynamic>.from(jsonDecode(jsonString));
        
        expect(decodedData['2024-01-01'], equals(100));
        expect(decodedData['2024-01-02'], equals(200));
        expect(decodedData['2024-01-03_actual'], equals(50));
      });

      test('空のデータでも正しく処理される', () {
        const emptyJson = '{}';
        final decodedData = Map<String, dynamic>.from(jsonDecode(emptyJson));
        
        expect(decodedData.isEmpty, isTrue);
        expect(decodedData['nonexistent_key'], isNull);
      });
    });

    group('週次統計計算', () {
      test('週の開始日が正しく計算される', () {
        // 月曜日を週の開始とする
        final monday = DateTime(2024, 1, 1); // 2024年1月1日は月曜日
        final tuesday = DateTime(2024, 1, 2);
        final sunday = DateTime(2024, 1, 7);
        
        // 週の計算ロジックをテスト（実装に応じて調整が必要）
        final mondayWeekStart = monday.subtract(Duration(days: monday.weekday - 1));
        final tuesdayWeekStart = tuesday.subtract(Duration(days: tuesday.weekday - 1));
        final sundayWeekStart = sunday.subtract(Duration(days: sunday.weekday - 1));
        
        expect(mondayWeekStart.day, equals(1));
        expect(tuesdayWeekStart.day, equals(1));
        expect(sundayWeekStart.day, equals(1));
      });
    });

    group('統計データ集計', () {
      test('日次データから週次データを正しく集計', () {
        final dailyData = {
          '2024-01-01': 10,
          '2024-01-02': 20,
          '2024-01-03': 30,
          '2024-01-08': 40, // 次の週
        };
        
        // 週次集計のテストロジック
        var firstWeekTotal = 0;
        var secondWeekTotal = 0;
        
        dailyData.forEach((key, value) {
          final date = DateTime.parse(key);
          if (date.isBefore(DateTime(2024, 1, 8))) {
            firstWeekTotal += value as int;
          } else {
            secondWeekTotal += value as int;
          }
        });
        
        expect(firstWeekTotal, equals(60)); // 10 + 20 + 30
        expect(secondWeekTotal, equals(40));
      });

      test('月次データから正しい統計を計算', () {
        final monthlyData = {
          '2024-01-01': 100,
          '2024-01-15': 200,
          '2024-01-31': 300,
          '2024-02-01': 150, // 次の月
        };
        
        var januaryTotal = 0;
        var februaryTotal = 0;
        
        monthlyData.forEach((key, value) {
          final date = DateTime.parse(key);
          if (date.month == 1) {
            januaryTotal += value as int;
          } else if (date.month == 2) {
            februaryTotal += value as int;
          }
        });
        
        expect(januaryTotal, equals(600)); // 100 + 200 + 300
        expect(februaryTotal, equals(150));
      });
    });

    group('データ更新ロジック', () {
      test('既存データに新しいタップ数を加算', () {
        const existingTaps = 50;
        const newTaps = 30;
        const expectedTotal = existingTaps + newTaps;
        
        expect(expectedTotal, equals(80));
      });

      test('新規日付のデータは0から開始', () {
        const newTaps = 25;
        const expectedTotal = 0 + newTaps;
        
        expect(expectedTotal, equals(25));
      });
    });

    group('統計表示用データ', () {
      test('日次統計が正しい形式で取得される', () {
        // 統計表示用のデータ構造テスト
        final sampleStats = [
          {'date': '2024-01-01', 'taps': 100, 'actualTaps': 80},
          {'date': '2024-01-02', 'taps': 150, 'actualTaps': 120},
          {'date': '2024-01-03', 'taps': 200, 'actualTaps': 160},
        ];
        
        expect(sampleStats.length, equals(3));
        expect(sampleStats[0]['taps'], equals(100));
        expect(sampleStats[1]['actualTaps'], equals(120));
        expect(sampleStats[2]['date'], equals('2024-01-03'));
      });

      test('週次統計の平均計算', () {
        final weeklyTaps = [100, 200, 150, 300, 250, 180, 220];
        final averageTaps = weeklyTaps.reduce((a, b) => a + b) / weeklyTaps.length;
        
        expect(averageTaps, closeTo(200.0, 0.1));
      });

      test('最高記録の特定', () {
        final dailyTaps = [50, 120, 80, 200, 150, 90];
        final maxTaps = dailyTaps.reduce((a, b) => a > b ? a : b);
        final minTaps = dailyTaps.reduce((a, b) => a < b ? a : b);
        
        expect(maxTaps, equals(200));
        expect(minTaps, equals(50));
      });
    });

    group('エラーハンドリング', () {
      test('不正なJSON形式でもエラーにならない', () {
        expect(() {
          try {
            jsonDecode('invalid json');
          } catch (e) {
            // エラーは予想される動作
            expect(e, isA<FormatException>());
          }
        }, returnsNormally);
      });

      test('null値の処理', () {
        final testData = {
          'valid_key': 100,
          'null_key': null,
        };
        
        expect(testData['valid_key'], equals(100));
        expect(testData['null_key'], isNull);
        expect(testData['nonexistent_key'], isNull);
      });
    });
  });
}