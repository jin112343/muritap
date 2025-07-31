import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// App Tracking Transparency (ATT) 管理サービス
/// iOS 14.5以降でのユーザートラッキング許可を管理
class TrackingService {
  static const MethodChannel _channel = MethodChannel('tracking_service');
  
  /// シングルトンインスタンス
  static final TrackingService instance = TrackingService._internal();
  TrackingService._internal();

  /// トラッキング許可の状態を取得
  Future<ATTTrackingStatus> getTrackingStatus() async {
    if (Platform.isIOS) {
      try {
        final int status = await _channel.invokeMethod('getTrackingStatus');
        return _convertToATTrackingStatus(status);
      } on PlatformException catch (e) {
        debugPrint('Error getting tracking status: $e');
        return ATTTrackingStatus.notDetermined;
      }
    }
    return ATTTrackingStatus.notDetermined;
  }

  /// トラッキング許可を要求
  Future<ATTTrackingStatus> requestTrackingAuthorization() async {
    if (Platform.isIOS) {
      try {
        final int status = await _channel.invokeMethod('requestTrackingAuthorization');
        return _convertToATTrackingStatus(status);
      } on PlatformException catch (e) {
        debugPrint('Error requesting tracking authorization: $e');
        return ATTTrackingStatus.notDetermined;
      }
    }
    return ATTTrackingStatus.notDetermined;
  }

  /// iOSのATTrackingManager.AuthorizationStatusの値をDartのenumに変換
  ATTTrackingStatus _convertToATTrackingStatus(int status) {
    switch (status) {
      case 0: // notDetermined
        return ATTTrackingStatus.notDetermined;
      case 1: // restricted
        return ATTTrackingStatus.restricted;
      case 2: // denied
        return ATTTrackingStatus.denied;
      case 3: // authorized
        return ATTTrackingStatus.authorized;
      default:
        return ATTTrackingStatus.notDetermined;
    }
  }

  /// トラッキング許可が必要かどうかを判定
  Future<bool> shouldRequestTracking() async {
    final status = await getTrackingStatus();
    return status == ATTTrackingStatus.notDetermined;
  }

  /// トラッキング許可が承認されているかどうかを判定
  Future<bool> isTrackingAuthorized() async {
    final status = await getTrackingStatus();
    return status == ATTTrackingStatus.authorized;
  }
}

/// ATTトラッキング許可の状態
/// iOS 14.5以降のATTrackingManager.trackingAuthorizationStatusと対応
enum ATTTrackingStatus {
  notDetermined,  // 未決定 (0)
  restricted,     // 制限されている (1)
  denied,         // 拒否 (2)
  authorized,     // 許可 (3)
} 