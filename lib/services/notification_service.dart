import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// 通知管理サービス
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// 通知サービスを初期化
  Future<void> initialize() async {
    try {
      // タイムゾーンデータを初期化
      tz.initializeTimeZones();
      
      // Android設定
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS設定
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: false, // バッジ権限を無効化
        requestSoundPermission: true,
      );

      // 初期化設定
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      // 初期化
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      );

      print('通知サービス初期化完了');
    } catch (e) {
      print('通知サービス初期化エラー: $e');
    }
  }

  /// 通知応答の処理
  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    print('通知がタップされました: ${response.payload}');
    // 必要に応じて通知タップ時の処理を追加
  }

  /// 煽る通知メッセージのリスト（多言語対応のためパラメータとして受け取る）
  static List<String> _motivationalMessages = [];

  /// ランダムな煽るメッセージを取得
  String _getRandomMotivationalMessage() {
    if (_motivationalMessages.isEmpty) {
      // デフォルトメッセージ（多言語設定が未実行の場合）
      return 'タップの時間です！';
    }
    final random = DateTime.now().millisecondsSinceEpoch % _motivationalMessages.length;
    return _motivationalMessages[random];
  }
  
  /// 通知メッセージを設定
  void setNotificationMessages(List<String> messages) {
    _motivationalMessages = messages;
  }

  /// 毎日20時の通知をスケジュール
  Future<void> scheduleDailyNotification(BuildContext context, {String? appName, String? channelName, String? channelDescription}) async {
    try {
      // 既存の通知をキャンセル
      await _flutterLocalNotificationsPlugin.cancel(1001);
      
      // 20時に通知をスケジュール
      final now = DateTime.now();
      final scheduledDate = DateTime(now.year, now.month, now.day, 20, 0, 0);
      
      // 今日の20時が過ぎている場合は明日の20時に設定
      final targetDate = scheduledDate.isBefore(now) 
          ? scheduledDate.add(const Duration(days: 1))
          : scheduledDate;
      
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        1001, // 通知ID
        appName ?? AppLocalizations.of(context)!.notificationAppName, // タイトル
        _getRandomMotivationalMessage(), // メッセージ
        tz.TZDateTime.from(targetDate, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder_channel',
            channelName ?? AppLocalizations.of(context)!.notificationChannelName,
            channelDescription: channelDescription ?? AppLocalizations.of(context)!.notificationChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // 毎日同じ時間に繰り返し
      );
      
      print('毎日20時の通知をスケジュールしました: ${targetDate.toString()}');
    } catch (e) {
      print('通知スケジュールエラー: $e');
    }
  }

  /// 毎日20時の通知をスケジュール（BuildContextなし、デフォルト言語）
  Future<void> scheduleDailyNotificationDefault({String? appName, String? channelName, String? channelDescription}) async {
    try {
      // 既存の通知をキャンセル
      await _flutterLocalNotificationsPlugin.cancel(1001);
      
      // 20時に通知をスケジュール
      final now = DateTime.now();
      final scheduledDate = DateTime(now.year, now.month, now.day, 20, 0, 0);
      
      // 今日の20時が過ぎている場合は明日の20時に設定
      final targetDate = scheduledDate.isBefore(now) 
          ? scheduledDate.add(const Duration(days: 1))
          : scheduledDate;
      
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        1001, // 通知ID
        appName ?? 'MURITAP', // デフォルトは英語
        _getRandomMotivationalMessage(), // メッセージ
        tz.TZDateTime.from(targetDate, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder_channel',
            channelName ?? 'Daily Reminder',
            channelDescription: channelDescription ?? 'Daily tap reminder at 8 PM',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // 毎日同じ時間に繰り返し
      );
      
      print('毎日20時の通知をスケジュールしました');
    } catch (e) {
      print('通知スケジュールエラー: $e');
    }
  }

  /// 毎日の通知をキャンセル
  Future<void> cancelDailyNotification() async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(1001);
      print('毎日の通知をキャンセルしました');
    } catch (e) {
      print('通知キャンセルエラー: $e');
    }
  }

  /// 通知のスケジュール状態を確認
  Future<bool> isDailyNotificationScheduled() async {
    try {
      final pendingNotifications = await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
      return pendingNotifications.any((notification) => notification.id == 1001);
    } catch (e) {
      print('通知状態確認エラー: $e');
      return false;
    }
  }

  /// すべての通知をクリア
  Future<void> clearAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      
      // バッジを確実にクリア
      await _clearBadge();
      
      print('すべての通知とバッジをクリアしました');
    } catch (e) {
      print('通知クリアエラー: $e');
    }
  }

  /// バッジをクリア
  Future<void> clearBadge() async {
    await _clearBadge();
  }

  /// バッジをクリアする内部メソッド
  Future<void> _clearBadge() async {
    try {
      // iOSの場合、バッジ数を0に設定
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: false,
            sound: true,
          );
      
      // バッジをクリアするために通知を0件で表示
      await _flutterLocalNotificationsPlugin.show(
        9999, // 一時的な通知ID
        '', // 空のタイトル
        '', // 空の本文
        const NotificationDetails(
          iOS: DarwinNotificationDetails(
            presentAlert: false,
            presentBadge: false,
            presentSound: false,
          ),
        ),
      );
      
      // すぐに通知をキャンセル
      await _flutterLocalNotificationsPlugin.cancel(9999);
      
      print('バッジをクリアしました');
    } catch (e) {
      print('バッジクリアエラー: $e');
    }
  }

  /// 特定の通知をクリア
  Future<void> clearNotification(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
      print('通知をクリアしました: $id');
    } catch (e) {
      print('通知クリアエラー: $e');
    }
  }

  /// 通知を表示
  Future<void> showNotification(BuildContext context, {
    required int id,
    required String title,
    required String body,
    String? payload,
    String? channelName,
    String? channelDescription,
  }) async {
    try {
      final AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'impossible_tap_channel',
        channelName ?? AppLocalizations.of(context)!.notificationGeneralChannelName,
        channelDescription: channelDescription ?? AppLocalizations.of(context)!.notificationGeneralChannelDescription,
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false, // バッジを無効化
        presentSound: true,
      );

      final NotificationDetails platformChannelSpecifics =
          NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );

      print('通知を表示しました: $title');
    } catch (e) {
      print('通知表示エラー: $e');
    }
  }

  /// 通知権限を要求
  Future<bool> requestPermissions() async {
    try {
      final bool? result = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: false, // バッジを無効化
            sound: true,
          );
      
      return result ?? false;
    } catch (e) {
      print('通知権限要求エラー: $e');
      return false;
    }
  }

  /// 通知権限の状態を確認
  Future<bool> areNotificationsEnabled() async {
    try {
      final bool? result = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: false, // バッジを無効化
            sound: true,
          );
      
      return result ?? false;
    } catch (e) {
      print('通知権限確認エラー: $e');
      return false;
    }
  }
} 