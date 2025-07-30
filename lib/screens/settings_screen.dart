import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../config/theme_config.dart';
import '../services/data_service.dart';
import 'webview_screen.dart';

/// 設定画面
/// アプリ情報と外部リンクを提供
class SettingsScreen extends HookWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = useState(false);

    // 外部リンクを開く
    Future<void> openUrl(String url) async {
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('リンクを開けませんでした'),
                backgroundColor: ThemeConfig.errorColor,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('エラーが発生しました: $e'),
              backgroundColor: ThemeConfig.errorColor,
            ),
          );
        }
      }
    }

    // メールを開く
    Future<void> launchEmail() async {
      final subject = Uri.encodeComponent('絶対ムリタップについて');
      final body = Uri.encodeComponent('''
お問い合わせ内容：



---
アプリ名: 絶対ムリタップ
バージョン: ${AppConfig.appVersion}
''');
      final emailUrl = 'mailto:mizoijin.0201@gmail.com?subject=$subject&body=$body';
      await openUrl(emailUrl);
    }

    // データをリセット
    Future<void> resetData() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('データリセット'),
          content: const Text('すべてのデータが削除されます。\nこの操作は取り消せません。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: ThemeConfig.errorColor,
              ),
              child: const Text('リセット'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        isLoading.value = true;
        try {
          await DataService.instance.resetData();
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('データをリセットしました'),
                backgroundColor: ThemeConfig.successColor,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('リセットに失敗しました: $e'),
                backgroundColor: ThemeConfig.errorColor,
              ),
            );
          }
        } finally {
          isLoading.value = false;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // アプリ情報
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.touch_app,
                      size: 64,
                      color: ThemeConfig.primaryColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppConfig.appName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // サポート
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('お問い合わせ'),
                    subtitle: const Text('バグ報告や機能要望'),
                    onTap: launchEmail,
                  ),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip),
                    title: const Text('プライバシーポリシー'),
                    subtitle: const Text('個人情報の取り扱い'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const WebViewScreen(
                            title: 'プライバシーポリシー',
                            url: AppConfig.privacyPolicyUrl,
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: const Text('利用規約'),
                    subtitle: const Text('アプリの利用条件'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const WebViewScreen(
                            title: '利用規約',
                            url: AppConfig.termsOfServiceUrl,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // データ管理
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: ThemeConfig.errorColor),
                    title: const Text('データリセット'),
                    subtitle: const Text('すべてのデータを削除'),
                    onTap: isLoading.value ? null : resetData,
                    trailing: isLoading.value 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                  ),
                ],
              ),
            ),
            
            const Spacer(),
          ],
        ),
      ),
    );
  }
} 