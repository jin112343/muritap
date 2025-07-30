import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:io';

import '../config/theme_config.dart';
import '../services/game_center_service.dart';
import '../services/data_service.dart';

/// ランキング画面
/// GameCenterとの連携でランキングを表示
class RankingScreen extends HookWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = useState(false);
    final isSignedIn = useState(false);
    final currentPlayerScore = useState<int?>(null);
    final lastSubmittedScore = useState<int?>(null);
    final leaderboardEntries = useState<List<LeaderboardEntry>>([]);
    final showInAppRanking = useState(false);

    // GameCenterサインイン
    Future<void> signInToGameCenter() async {
      isLoading.value = true;
      try {
        final success = await GameCenterService.instance.signIn();
        isSignedIn.value = success;
        if (success) {
          // サインイン成功後、現在のスコアを取得
          final score = await GameCenterService.instance.getCurrentPlayerScore();
          currentPlayerScore.value = score;
        }
      } catch (e) {
        print('GameCenter sign in error: $e');
      } finally {
        isLoading.value = false;
      }
    }

    // リーダーボード表示
    Future<void> showLeaderboard() async {
      if (!isSignedIn.value) {
        await signInToGameCenter();
      }
      
      if (isSignedIn.value) {
        await GameCenterService.instance.showLeaderboard();
      }
    }

    // アプリ内ランキングを表示
    Future<void> loadInAppRanking() async {
      if (!isSignedIn.value) {
        await signInToGameCenter();
      }
      
      if (isSignedIn.value) {
        isLoading.value = true;
        try {
          final entries = await GameCenterService.instance.getLeaderboardEntries();
          leaderboardEntries.value = entries;
          showInAppRanking.value = true;
        } catch (e) {
          print('Error loading leaderboard entries: $e');
        } finally {
          isLoading.value = false;
        }
      }
    }

    // タップ回数をスコアとして送信
    Future<void> submitTapScore() async {
      if (!isSignedIn.value) {
        await signInToGameCenter();
      }
      
      if (isSignedIn.value) {
        final totalTaps = DataService.instance.getTotalTaps();
        final success = await GameCenterService.instance.submitScore(totalTaps);
        if (success) {
          lastSubmittedScore.value = totalTaps;
          // 送信後、現在のスコアを更新
          final score = await GameCenterService.instance.getCurrentPlayerScore();
          currentPlayerScore.value = score;
          
          // ランキングを更新
          if (showInAppRanking.value) {
            await loadInAppRanking();
          }
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('タップ回数 ${totalTaps}回 を送信しました！'),
                backgroundColor: ThemeConfig.successColor,
              ),
            );
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('スコアの送信に失敗しました'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }



    // 初期化時にGameCenterサインインとランキング表示を試行
    useEffect(() {
      if (Platform.isIOS) {
        signInToGameCenter().then((_) {
          if (isSignedIn.value) {
            loadInAppRanking();
          }
        });
      }
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ランキング'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 現在の記録表示
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'あなたの記録',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '累積タップ数: ${DataService.instance.getTotalTaps()}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      '現在レベル: ${DataService.instance.getCurrentLevel()}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (currentPlayerScore.value != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'GameCenter記録: ${currentPlayerScore.value}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ThemeConfig.primaryColor,
                        ),
                      ),
                    ],
                    if (lastSubmittedScore.value != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '最後に送信: ${lastSubmittedScore.value}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // GameCenter連携ボタン
            if (Platform.isIOS) ...[
              ElevatedButton.icon(
                onPressed: isLoading.value ? null : showLeaderboard,
                icon: isLoading.value 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.leaderboard),
                label: Text(
                  isLoading.value 
                    ? '読み込み中...' 
                    : (isSignedIn.value ? 'GameCenterで見る' : 'GameCenterにサインイン'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConfig.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
              
              const SizedBox(height: 16),
              
              ElevatedButton.icon(
                onPressed: isLoading.value ? null : submitTapScore,
                icon: isLoading.value 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload),
                label: Text(
                  isLoading.value 
                    ? '送信中...' 
                    : 'タップ回数を送信',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConfig.accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
              

            ] else ...[
              // Android用のメッセージ
              Card(
                color: Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'GameCenterはiOSのみ対応',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'タップ回数のランキング機能はiOSデバイスでのみ利用できます。',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            // アプリ内ランキング表示
            if (showInAppRanking.value && leaderboardEntries.value.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'ランキング',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              showInAppRanking.value = false;
                              leaderboardEntries.value = [];
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 300,
                        child: ListView.builder(
                          itemCount: leaderboardEntries.value.length,
                          itemBuilder: (context, index) {
                            final entry = leaderboardEntries.value[index];
                            return ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: entry.isCurrentPlayer 
                                    ? ThemeConfig.primaryColor 
                                    : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    '${entry.rank}',
                                    style: TextStyle(
                                      color: entry.isCurrentPlayer 
                                        ? Colors.white 
                                        : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                entry.playerName,
                                style: TextStyle(
                                  fontWeight: entry.isCurrentPlayer 
                                    ? FontWeight.bold 
                                    : FontWeight.normal,
                                  color: entry.isCurrentPlayer 
                                    ? ThemeConfig.primaryColor 
                                    : null,
                                ),
                              ),
                              trailing: Text(
                                '${entry.score}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: entry.isCurrentPlayer 
                                    ? ThemeConfig.primaryColor 
                                    : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // 説明文
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ランキングについて',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• 累積タップ数がランキングに反映されます\n'
                      '• レベルアップ時に自動でスコアが送信されます\n'
                      '• 手動でも「タップ回数を送信」で送信できます\n'
                      '• アプリ内でランキングが自動表示されます\n'
                      '• 「GameCenterで見る」で標準のGameCenter画面も利用可能',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 