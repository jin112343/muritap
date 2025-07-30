import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';
import '../config/app_config.dart';

/// 広告管理サービス
/// 可用性を保つため、広告の読み込み失敗時もアプリは動作する
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  static AdService get instance => _instance;
  
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  /// バナー広告を読み込み
  Future<void> loadBannerAd() async {
    try {
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
            print('Banner ad loaded successfully');
          },
          onAdFailedToLoad: (ad, error) {
            _isBannerAdLoaded = false;
            print('Banner ad failed to load: $error');
            ad.dispose();
          },
        ),
      );
      
      await _bannerAd!.load();
    } catch (e) {
      // 可用性を保つため、広告の読み込み失敗は無視
      print('Error loading banner ad: $e');
      _isBannerAdLoaded = false;
    }
  }

  /// バナー広告ウィジェットを取得
  Widget? getBannerAdWidget() {
    if (_isBannerAdLoaded && _bannerAd != null) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return null;
  }

  /// 広告を破棄
  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdLoaded = false;
  }

  /// 広告が読み込まれているかチェック
  bool get isBannerAdLoaded => _isBannerAdLoaded;
} 