import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:io';
import 'dart:async'; // Timerを追加
import 'dart:developer' as developer;

import '../config/theme_config.dart';
import '../services/game_center_service.dart';
import '../services/play_games_service.dart';
import '../services/data_service.dart';
import '../services/share_service.dart';
import '../services/ad_service.dart'; // AdServiceを追加
import '../l10n/app_localizations.dart';

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
    
    // リアルタイムデータ監視
    final currentTaps = useState(0); // 初期値は0に設定
    final totalTapsForGameCenter = useState(0); // 初期値は0に設定
    final currentLevel = useState(1); // 初期値は1に設定
    
    // データを定期的に更新
    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        currentTaps.value = DataService.instance.getTotalTaps();
        totalTapsForGameCenter.value = DataService.instance.getTotalTaps();
        currentLevel.value = DataService.instance.getCurrentLevel();
      });
      
      return timer.cancel;
    }, []);
    
    // スクリーンショット用のキー
    final screenshotKey = useMemoized(() => GlobalKey(), []);

    // 共有ボタンの処理
    void onShare() async {
      // スクリーンショット時に広告を非表示にする
      AdService.instance.hideAd();
      
      // 少し待ってからスクリーンショットを撮影（UI更新のため）
      await Future.delayed(const Duration(milliseconds: 100));
      
      try {
        await ShareService.instance.shareScreenshot(
          screenshotKey,
          text: AppLocalizations.of(context)!.rankingShareText(
            currentLevel.value.toString(),
            currentTaps.value.toString(),
          ),
        );
      } finally {
        // 共有完了後、広告を再表示
        AdService.instance.showAd();
      }
    }

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
        developer.log('GameCenter sign in error: $e');
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
          developer.log('Error loading leaderboard entries: $e');
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
        final scoreToSubmit = DataService.instance.getTotalTaps(); // 累計数（倍率適用後）
        final success = await GameCenterService.instance.submitScore(scoreToSubmit);
        if (success) {
          lastSubmittedScore.value = scoreToSubmit;
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
                content: Text(AppLocalizations.of(context)!.dialogsScoreSubmitSuccess(scoreToSubmit.toString())),
                backgroundColor: ThemeConfig.successColor,
              ),
            );
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
              content: Text(AppLocalizations.of(context)!.dialogsScoreSubmitFailed),
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
        title: Text(AppLocalizations.of(context)!.rankingTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // 共有ボタン
          IconButton(
            onPressed: onShare,
            icon: const Icon(
              Icons.share,
              color: ThemeConfig.primaryColor,
            ),
            tooltip: AppLocalizations.of(context)!.rankingShareTooltip,
          ),
        ],
      ),
      body: RepaintBoundary(
        key: screenshotKey,
        child: Container(
          color: ThemeConfig.backgroundColor, // 背景色を設定
          child: SingleChildScrollView(
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
                        Text(
                          AppLocalizations.of(context)!.rankingYourRecord,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${AppLocalizations.of(context)!.rankingTotalTaps}: ${currentTaps.value}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          '${AppLocalizations.of(context)!.rankingCurrentLevel}: ${currentLevel.value}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (currentPlayerScore.value != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${AppLocalizations.of(context)!.rankingGameCenterRecord}: ${currentPlayerScore.value}',
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
                            '${AppLocalizations.of(context)!.rankingLastSubmitted}: ${lastSubmittedScore.value}',
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
                        ? AppLocalizations.of(context)!.rankingLoading
                        : (isSignedIn.value ? AppLocalizations.of(context)!.rankingViewInGameCenter : AppLocalizations.of(context)!.rankingSignInToGameCenter),
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
                        ? AppLocalizations.of(context)!.rankingUploading
                        : AppLocalizations.of(context)!.rankingSubmitTaps,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConfig.accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                  

                ] else if (Platform.isAndroid) ...[
                  // Android用のPlay Gamesボタン
                  ElevatedButton.icon(
                    onPressed: isLoading.value ? null : () async {
                      if (!isSignedIn.value) {
                        isLoading.value = true;
                        try {
                          final success = await PlayGamesService.instance.signIn();
                          isSignedIn.value = success;
                        } catch (e) {
                          developer.log('Play Games sign in error: $e');
                        } finally {
                          isLoading.value = false;
                        }
                      }

                      if (isSignedIn.value) {
                        await PlayGamesService.instance.showLeaderboard();
                      }
                    },
                    icon: isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.leaderboard),
                    label: Text(
                      isLoading.value
                        ? AppLocalizations.of(context)!.rankingLoading
                        : (isSignedIn.value ? AppLocalizations.of(context)!.rankingViewInPlayGames : AppLocalizations.of(context)!.rankingSignInToPlayGames),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConfig.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    onPressed: isLoading.value ? null : () async {
                      if (!isSignedIn.value) {
                        isLoading.value = true;
                        try {
                          final success = await PlayGamesService.instance.signIn();
                          isSignedIn.value = success;
                        } catch (e) {
                          developer.log('Play Games sign in error: $e');
                        } finally {
                          isLoading.value = false;
                        }
                      }

                      if (isSignedIn.value) {
                        final scoreToSubmit = DataService.instance.getTotalTaps();
                        final success = await PlayGamesService.instance.submitScore(scoreToSubmit);
                        if (success) {
                          lastSubmittedScore.value = scoreToSubmit;

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)!.dialogsScoreSubmitSuccess(scoreToSubmit.toString())),
                                backgroundColor: ThemeConfig.successColor,
                              ),
                            );
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)!.dialogsScoreSubmitFailed),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                    icon: isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload),
                    label: Text(
                      isLoading.value
                        ? AppLocalizations.of(context)!.rankingUploading
                        : AppLocalizations.of(context)!.rankingSubmitTaps,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConfig.accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
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
                              Text(
                                AppLocalizations.of(context)!.rankingLeaderboard,
                                style: const TextStyle(
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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.rankingAbout,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.rankingAboutDescription,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 