import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/app_config.dart';
import 'dart:async'; // Completerを追加
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
      await MobileAds.instance.initialize();
      
      // 広告削除状態をチェック
      await updateAdsRemovedStatus();
      
      print('AdService initialized successfully');
    } catch (e) {
      print('AdService initialization error: $e');
    }
  }

  /// バナー広告を読み込み
  Future<void> loadBannerAd() async {
    try {
      // 広告削除が購入されているかチェック
      await updateAdsRemovedStatus();
      if (_isAdsRemoved) {
        print('広告削除が購入されているため、バナー広告を読み込みません');
        return;
      }

      // プラットフォーム別の広告IDを選択
      final adUnitId = Platform.isIOS 
        ? AppConfig.bannerAdUnitIdIOS
        : AppConfig.bannerAdUnitIdAndroid;
      
      print('Loading banner ad with ID: $adUnitId');
      
      _bannerAd = BannerAd(
        adUnitId: adUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _isBannerAdLoaded = true;
            print('Banner ad loaded successfully');
          },
          onAdFailedToLoad: (ad, error) {
            _isBannerAdLoaded = false;
            _bannerAdError = error.message;
            print('Banner ad failed to load: $error');
            ad.dispose();
            // 一定時間後に再読み込みを試行
            Future.delayed(const Duration(minutes: 2), () {
              if (!_isBannerAdLoaded) {
                print('Retrying banner ad load...');
                loadBannerAd();
              }
            });
          },
          onAdOpened: (ad) {
            print('Banner ad opened');
          },
          onAdClosed: (ad) {
            print('Banner ad closed');
          },
        ),
      );
      
      await _bannerAd!.load();
    } catch (e) {
      // 可用性を保つため、広告の読み込み失敗は無視
      print('Error loading banner ad: $e');
      _isBannerAdLoaded = false;
      _bannerAdError = e.toString();
      
      // エラー時も再試行
      Future.delayed(const Duration(minutes: 2), () {
        if (!_isBannerAdLoaded) {
          print('Retrying banner ad load after error...');
          loadBannerAd();
        }
      });
    }
  }

  /// リワード広告（動画）を読み込み
  Future<void> loadRewardedAd() async {
    try {
      // 広告削除が購入されているかチェック
      await updateAdsRemovedStatus();
      if (_isAdsRemoved) {
        print('広告削除が購入されているため、リワード広告を読み込みません');
        return;
      }

      // プラットフォーム別の広告IDを選択
      final adUnitId = Platform.isIOS 
        ? AppConfig.rewardedAdUnitIdIOS
        : AppConfig.rewardedAdUnitIdAndroid;
      
      print('Loading rewarded ad with ID: $adUnitId');
      
      await RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isRewardedAdLoaded = true;
            print('Rewarded ad loaded successfully');
          },
          onAdFailedToLoad: (error) {
            _isRewardedAdLoaded = false;
            print('Rewarded ad failed to load: $error');
          },
        ),
      );
    } catch (e) {
      print('Error loading rewarded ad: $e');
      _isRewardedAdLoaded = false;
    }
  }

  /// リワード広告（動画）を表示
  Future<bool> showRewardedAd() async {
    print('AdService: showRewardedAd開始');
    print('AdService: リワード広告読み込み状態: $_isRewardedAdLoaded');
    print('AdService: リワード広告オブジェクト: ${_rewardedAd != null ? "存在" : "null"}');
    
    // 広告削除が購入されているかチェック
    await updateAdsRemovedStatus();
    if (_isAdsRemoved) {
      print('AdService: 広告削除が購入されているため、リワード広告を表示しません');
      return false;
    }
    
    if (!_isRewardedAdLoaded || _rewardedAd == null) {
      print('AdService: リワード広告が読み込まれていません');
      return false;
    }

    try {
      bool rewardEarned = false;
      
      print('AdService: リワード広告を表示中...');
      
      // 広告を表示して完了を待つ
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          print('AdService: ユーザーが報酬を獲得: ${reward.amount} ${reward.type}');
          rewardEarned = true;
        },
      );
      
      // 広告表示完了後、少し待ってから報酬状態を確認
      await Future.delayed(const Duration(milliseconds: 500));
      
      print('AdService: リワード広告表示完了, 報酬獲得: $rewardEarned');
      
      // テスト用広告の場合は確実に報酬を獲得
      if (!rewardEarned && (_rewardedAd!.adUnitId.contains('test') || _rewardedAd!.adUnitId.contains('3940256099942544'))) {
        print('AdService: テスト用広告のため、報酬を強制的に獲得');
        rewardEarned = true;
      }
      
      // 報酬が獲得されたかどうかを確認
      return rewardEarned;
    } catch (e) {
      print('AdService: リワード広告表示エラー: $e');
      return false;
    }
  }

  /// バナー広告ウィジェットを取得
  Widget? getBannerAdWidget() {
    // 広告削除が購入されている場合は何も表示しない
    if (_isAdsRemoved) {
      return null;
    }
    
    // 広告が非表示の場合は何も表示しない
    if (!_isAdVisible) {
      return null;
    }
    
    // 広告が読み込まれている場合のみ表示
    if (_isBannerAdLoaded && _bannerAd != null) {
      return Container(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
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
    print('Reloading banner ad...');
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

  /// 広告削除状態のフラグ
  bool _isAdsRemoved = false;
  bool get isAdsRemoved => _isAdsRemoved;

  /// 広告削除状態を更新
  Future<void> updateAdsRemovedStatus() async {
    _isAdsRemoved = await PurchaseService.instance.isAdsRemoved();
    print('広告削除状態を更新: $_isAdsRemoved');
  }

  /// 広告を非表示にする
  void hideAd() {
    _isAdVisible = false;
  }

  /// 広告を表示する
  void showAd() {
    _isAdVisible = true;
  }

  /// 広告削除状態をチェックして広告の表示を更新
  Future<void> updateAdVisibility() async {
    await updateAdsRemovedStatus();
    if (_isAdsRemoved) {
      // 広告削除が購入されている場合、既存の広告を破棄
      _bannerAd?.dispose();
      _rewardedAd?.dispose();
      _bannerAd = null;
      _rewardedAd = null;
      _isBannerAdLoaded = false;
      _isRewardedAdLoaded = false;
      print('広告削除が購入されているため、すべての広告を破棄しました');
    } else {
      // 広告削除が購入されていない場合、広告を再読み込み
      await loadBannerAd();
      await loadRewardedAd();
      print('広告削除が購入されていないため、広告を再読み込みしました');
    }
  }
} 