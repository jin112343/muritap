import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

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
      // Android設定
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS設定
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
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

  /// すべての通知をクリア
  Future<void> clearAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      print('すべての通知をクリアしました');
    } catch (e) {
      print('通知クリアエラー: $e');
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
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'impossible_tap_channel',
        '絶対ムリタップ',
        channelDescription: '絶対ムリタップの通知',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics =
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
            badge: true,
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
            badge: true,
            sound: true,
          );
      
      return result ?? false;
    } catch (e) {
      print('通知権限確認エラー: $e');
      return false;
    }
  }
} 