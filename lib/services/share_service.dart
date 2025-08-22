import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

/// 共有管理サービス
class ShareService {
  static final ShareService _instance = ShareService._internal();
  factory ShareService() => _instance;
  ShareService._internal();

  static ShareService get instance => _instance;

  /// テキストを共有
  Future<void> shareText(String text, {String? subject}) async {
    try {
      await Share.share(
        text,
        subject: subject,
      );
    } catch (e) {
      print('Error sharing text: $e');
    }
  }

  /// スクリーンショットを撮影して共有
  Future<void> shareScreenshot(GlobalKey screenshotKey, {String? text, String? subject}) async {
    try {
      // スクリーンショットを撮影
      final RenderRepaintBoundary boundary = screenshotKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 一時ファイルに保存
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/screenshot.png');
      await file.writeAsBytes(pngBytes);

      // 共有
      await Share.shareXFiles(
        [XFile(file.path)],
        text: text ?? 'MURITAPで遊んでいます！',
        subject: subject ?? 'MURITAP',
      );
    } catch (e) {
      print('Error sharing screenshot: $e');
    }
  }

  /// アプリの情報を共有
  Future<void> shareAppInfo({String? appInfo, String? subject}) async {
    final defaultAppInfo = '''
MURITAP

🎮 中毒性抜群のタップゲーム
📈 レベルアップで称号獲得
🏆 ランキングで競争
🎁 動画視聴で報酬獲得
💰 課金でタップ倍率アップ

#MURITAP #タップゲーム #ゲーム
''';

    await shareText(appInfo ?? defaultAppInfo, subject: subject ?? 'MURITAP');
  }
} 