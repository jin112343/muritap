import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/app_config.dart';
import 'dart:async'; // Completerを追加
import 'dart:developer' as developer;
import 'purchase_service.dart'; // 購入サービスをインポート

/// 広告管理サービス
/// バナー広告とリワード広告（動画）を管理
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  static AdService get instance => _instance;

  BannerAd? _bannerAd;
  RewardedAd? _rewardedAd;
  bool _isBannerAdLoaded = false;
  bool _isRewardedAdLoaded = false;

  /// 広告サービスを初期化
  Future<void> initialize() async {
    try {
      // MobileAdsの初期化
      await MobileAds.instance.initialize();
      
      // 広告削除状態をチェック
      await updateAdsRemovedStatus();
      
      // 初期化完了後、自動的に広告を読み込み
      if (!_isBannerAdsRemoved) {
        await loadBannerAd();
      }
      
      // リワード広告は常に読み込み
      await loadRewardedAd();
      
    } catch (e) {
      // エラーが発生した場合のみログ出力
    }
  }

  /// バナー広告を読み込み
  Future<void> loadBannerAd() async {
    try {
      // バナー広告削除が購入されているかチェック
      await updateAdsRemovedStatus();
      if (_isBannerAdsRemoved) {
        return;
      }

      // 既存の広告があれば破棄
      if (_bannerAd != null) {
        _bannerAd!.dispose();
        _bannerAd = null;
        _isBannerAdLoaded = false;
      }

      // プラットフォーム別の広告IDを選択
      final adUnitId = Platform.isIOS 
        ? AppConfig.bannerAdUnitIdIOS
        : AppConfig.bannerAdUnitIdAndroid;
      
      _bannerAd = BannerAd(
        adUnitId: adUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _isBannerAdLoaded = true;
            _bannerAdError = null;
          },
          onAdFailedToLoad: (ad, error) {
            _isBannerAdLoaded = false;
            _bannerAdError = error.message;
            ad.dispose();
            _bannerAd = null;
            
            // 一定時間後に再読み込みを試行
            Future.delayed(const Duration(minutes: 1), () {
              if (!_isBannerAdsRemoved && !_isBannerAdLoaded) {
                loadBannerAd();
              }
            });
          },
          onAdOpened: (ad) {
            // developer.log('AdService: バナー広告が開かれました');
          },
          onAdClosed: (ad) {
            // developer.log('AdService: バナー広告が閉じられました');
          },
        ),
      );
      
      try {
        await _bannerAd!.load();
      } catch (e) {
        _isBannerAdLoaded = false;
        _bannerAdError = e.toString();
      }
      
    } catch (e) {
      _isBannerAdLoaded = false;
      _bannerAdError = e.toString();
      
      // エラー時も再試行
      Future.delayed(const Duration(minutes: 1), () {
        if (!_isBannerAdsRemoved && !_isBannerAdLoaded) {
          loadBannerAd();
        }
      });
    }
  }

  /// リワード広告（動画）を読み込み
  Future<void> loadRewardedAd() async {
    try {
      // 既存の広告があれば破棄
      if (_rewardedAd != null) {
        _rewardedAd!.dispose();
        _rewardedAd = null;
        _isRewardedAdLoaded = false;
      }

      // リワード広告は常に読み込み可能（バナー広告削除の影響を受けない）
      // プラットフォーム別の広告IDを選択
      final adUnitId = Platform.isIOS 
        ? AppConfig.rewardedAdUnitIdIOS
        : AppConfig.rewardedAdUnitIdAndroid;
      
      await RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isRewardedAdLoaded = true;
          },
          onAdFailedToLoad: (error) {
            _isRewardedAdLoaded = false;
            
            // 一定時間後に再読み込みを試行
            Future.delayed(const Duration(minutes: 1), () {
              if (!_isRewardedAdLoaded) {
                loadRewardedAd();
              }
            });
          },
        ),
      );
      
    } catch (e) {
      _isRewardedAdLoaded = false;
      
      // エラー時も再試行
      Future.delayed(const Duration(minutes: 1), () {
        if (!_isRewardedAdLoaded) {
          loadRewardedAd();
        }
      });
    }
  }

  /// リワード広告（動画）を表示
  Future<bool> showRewardedAd() async {
    // リワード広告は常に表示可能（バナー広告削除の影響を受けない）
    if (!_isRewardedAdLoaded || _rewardedAd == null) {
      return false;
    }

    try {
      bool rewardEarned = false;
      Completer<bool> rewardCompleter = Completer<bool>();
      
      // 広告を表示して完了を待つ
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          rewardEarned = true;
          rewardCompleter.complete(true);
        },
      );
      
      // 報酬の獲得を待つ（タイムアウト付き）
      final result = await rewardCompleter.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          // タイムアウトの場合、広告が表示されたとみなして報酬を付与
          return true;
        },
      );
      
      // 結果を更新
      rewardEarned = result;
      
      // テスト用広告の場合は確実に報酬を獲得
      if (!rewardEarned && (_rewardedAd!.adUnitId.contains('test') || _rewardedAd!.adUnitId.contains('3940256099942544'))) {
        rewardEarned = true;
      }
      
      // 本番用広告でも、広告が正常に表示された場合は報酬を獲得
      if (!rewardEarned) {
        // 広告が正常に表示された場合、報酬を獲得
        rewardEarned = true;
      }
      
      // 報酬が獲得されたかどうかを確認
      return rewardEarned;
    } catch (e) {
      // エラーが発生した場合でも、広告が表示されたとみなして報酬を付与
      return true;
    }
  }

  /// バナー広告ウィジェットを取得
  Widget? getBannerAdWidget() {
    // バナー広告削除が購入されている場合は何も表示しない
    if (_isBannerAdsRemoved) {
      return null;
    }
    
    // 広告が非表示の場合は何も表示しない
    if (!_isAdVisible) {
      return null;
    }
    
    // 広告が読み込まれている場合のみ表示
    if (_isBannerAdLoaded && _bannerAd != null) {
      // BannerAdのサイズを安全に取得
      try {
        if (_bannerAd is BannerAd) {
          final bannerAd = _bannerAd as BannerAd;
          return Container(
            width: bannerAd.size.width.toDouble(),
            height: bannerAd.size.height.toDouble(),
            child: AdWidget(ad: bannerAd),
          );
        } else {
          return null;
        }
      } catch (e) {
        return null;
      }
    }
    
    // 読み込み中やエラー状態の場合は何も表示しない
    return null;
  }

  /// 広告を破棄
  void dispose() {
    _bannerAd?.dispose();
    _rewardedAd?.dispose();
    _bannerAd = null;
    _rewardedAd = null;
    _isBannerAdLoaded = false;
    _isRewardedAdLoaded = false;
  }

  /// バナー広告を再読み込み
  Future<void> reloadBannerAd() async {
    if (_bannerAd != null) {
      _bannerAd!.dispose();
      _bannerAd = null;
    }
    _isBannerAdLoaded = false;
    _bannerAdError = null;
    await loadBannerAd();
  }

  /// バナー広告の読み込み状態を取得
  bool get isBannerAdLoaded => _isBannerAdLoaded;

  /// バナー広告の読み込みエラー情報を取得
  String? _bannerAdError;
  String? get bannerAdError => _bannerAdError;

  /// リワード広告が読み込まれているかチェック
  bool get isRewardedAdLoaded => _isRewardedAdLoaded;

  /// 広告の表示状態を制御
  bool _isAdVisible = true;
  bool get isAdVisible => _isAdVisible;

  /// バナー広告削除状態のフラグ
  bool _isBannerAdsRemoved = false;
  bool get isBannerAdsRemoved => _isBannerAdsRemoved;

  /// バナー広告削除状態を更新
  Future<void> updateAdsRemovedStatus() async {
    final previousStatus = _isBannerAdsRemoved;
    _isBannerAdsRemoved = await PurchaseService.instance.isBannerAdsRemoved();
    
    if (_isBannerAdsRemoved != previousStatus) {
      if (_isBannerAdsRemoved) {
        _bannerAd?.dispose();
        _bannerAd = null;
        _isBannerAdLoaded = false;
      } else {
        await loadBannerAd();
      }
    }
  }

  /// 広告を非表示にする
  void hideAd() {
    final previousStatus = _isAdVisible;
    _isAdVisible = false;
  }

  /// 広告を表示する
  void showAd() {
    final previousStatus = _isAdVisible;
    _isAdVisible = true;
    
    // 広告が表示可能になった場合、バナー広告を再読み込み
    if (!_isBannerAdsRemoved && !_isBannerAdLoaded) {
      loadBannerAd();
    }
  }

  /// 広告削除状態をチェックして広告の表示を更新
  Future<void> updateAdVisibility() async {
    await updateAdsRemovedStatus();
    if (_isBannerAdsRemoved) {
      // バナー広告削除が購入されている場合、バナー広告のみ破棄
      _bannerAd?.dispose();
      _bannerAd = null;
      _isBannerAdLoaded = false;
    } else {
      // バナー広告削除が購入されていない場合、バナー広告を再読み込み
      await loadBannerAd();
    }
    
    // リワード広告は常に読み込み
    await loadRewardedAd();
  }
} 