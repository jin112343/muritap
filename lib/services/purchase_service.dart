import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../l10n/app_localizations.dart';

/// 課金管理サービス
class PurchaseService {
  static final PurchaseService instance = PurchaseService._internal();
  PurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final List<ProductDetails> _products = [];
  bool _isAvailable = false;
  
  // 年齢確認の状態を管理
  bool _isAgeVerified = false;

  // 商品ID - プラットフォーム別
  static final String removeAds = Platform.isIOS 
    ? 'com.impossibletap.removeads' 
    : 'android.test.purchased';
  static final String tap10 = Platform.isIOS 
    ? 'com.impossibletap.tap10' 
    : 'android.test.canceled';
  static final String tap100 = Platform.isIOS 
    ? 'com.impossibletap.tap100' 
    : 'android.test.item_unavailable';
  static final String tap1000 = Platform.isIOS 
    ? 'com.impossibletap.tap1000' 
    : 'android.test.refunded';
  // static final String tap1M = Platform.isIOS 
  //   ? 'com.impossibletap.tap1m' 
  //   : 'android.test.tap1m';
  // static final String tap100M = Platform.isIOS 
  //   ? 'com.impossibletap.tap100m' 
  //   : 'android.test.tap100m';

  /// 課金サービスを初期化
  Future<void> initialize() async {
    try {
      _isAvailable = await _inAppPurchase.isAvailable();
      print('課金利用可能: $_isAvailable');
      
      if (_isAvailable) {
        await _loadProducts();
        // 購入リスナーを設定
        _inAppPurchase.purchaseStream.listen(_onPurchaseUpdate);
        
        // iOS Sandbox環境でのテスト用設定
        if (Platform.isIOS) {
          print('iOS環境で実行中 - Sandbox環境でのテストを確認してください');
          print('Sandbox環境でテストするには、App Store ConnectでSandboxテスターを設定してください');
        }
      } else {
        print('課金が利用できません');
      }
      print('課金サービス初期化完了: $_isAvailable');
    } catch (e) {
      print('課金サービス初期化エラー: $e');
      _isAvailable = false;
    }
  }

  /// 購入更新のリスナー
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    print('=== 購入更新リスナー呼び出し ===');
    print('更新件数: ${purchaseDetailsList.length}件');
    
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      print('--- 購入詳細 ---');
      print('商品ID: ${purchaseDetails.productID}');
      print('購入ID: ${purchaseDetails.purchaseID}');
      print('ステータス: ${purchaseDetails.status}');
      print('検証データ: ${purchaseDetails.verificationData}');
      
      if (purchaseDetails.status == PurchaseStatus.pending) {
        print('⏳ 購入保留中: ${purchaseDetails.productID}');
      } else if (purchaseDetails.status == PurchaseStatus.purchased) {
        print('✅ 購入成功: ${purchaseDetails.productID}');
        print('購入ID: ${purchaseDetails.purchaseID}');
        // 購入状態を保存
        setProductPurchased(purchaseDetails.productID);
        // 購入完了を確認
        _inAppPurchase.completePurchase(purchaseDetails);
        print('✅ 購入完了処理完了: ${purchaseDetails.productID}');
      } else if (purchaseDetails.status == PurchaseStatus.restored) {
        print('🔄 購入復元: ${purchaseDetails.productID}');
        // 購入状態を保存
        setProductPurchased(purchaseDetails.productID);
        // 購入完了を確認
        _inAppPurchase.completePurchase(purchaseDetails);
        print('✅ 購入復元処理完了: ${purchaseDetails.productID}');
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        print('❌ 購入エラー: ${purchaseDetails.productID}');
        print('エラー詳細: ${purchaseDetails.error?.message}');
        print('エラーコード: ${purchaseDetails.error?.code}');
        print('エラー詳細: ${purchaseDetails.error}');
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        print('❌ 購入キャンセル: ${purchaseDetails.productID}');
      } else {
        print('❓ 不明な購入ステータス: ${purchaseDetails.status}');
      }
      print('--- 購入詳細終了 ---');
    }
    print('=== 購入更新リスナー終了 ===');
  }

  /// 商品を読み込み
  Future<void> _loadProducts() async {
    final Set<String> productIds = {
      removeAds,
      tap10,
      tap100,
      tap1000,
      // tap1M, // コメントアウト
      // tap100M, // コメントアウト
    };

    print('商品読み込み開始: $productIds');

    try {
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds);
      
      if (response.notFoundIDs.isNotEmpty) {
        print('見つからない商品ID: ${response.notFoundIDs}');
        print('⚠️ 見つからない商品の詳細:');
        for (final missingId in response.notFoundIDs) {
          print('  - $missingId');
          if (missingId == removeAds) {
            print('    → 広告削除商品がApp Store Connectで設定されていない可能性があります');
          } else if (missingId == tap10) {
            print('    → タップ10商品がApp Store Connectで設定されていない可能性があります');
          } else if (missingId == tap100) {
            print('    → タップ100商品がApp Store Connectで設定されていない可能性があります');
          } else if (missingId == tap1000) {
            print('    → タップ1000商品がApp Store Connectで設定されていない可能性があります');
          }
        }
      }

      if (response.error != null) {
        print('商品読み込みエラー: ${response.error}');
        print('エラー詳細: ${response.error!.message}');
        print('エラーコード: ${response.error!.code}');
      }

      _products.clear();
      _products.addAll(response.productDetails);
      print('読み込み完了商品数: ${_products.length}');
      
      if (_products.isNotEmpty) {
        print('✅ 正常に読み込まれた商品:');
        for (final product in _products) {
          print('  - ${product.id} - ${product.title} - ${product.price}');
        }
      } else {
        print('❌ 商品が1つも読み込まれませんでした');
      }
      
      // 商品の種類別の確認
      print('商品種類別確認:');
      print('  - 広告削除: ${_products.any((p) => p.id == removeAds) ? "✅" : "❌"}');
      print('  - タップ10: ${_products.any((p) => p.id == tap10) ? "✅" : "❌"}');
      print('  - タップ100: ${_products.any((p) => p.id == tap100) ? "✅" : "❌"}');
      print('  - タップ1000: ${_products.any((p) => p.id == tap1000) ? "✅" : "❌"}');
      // print('  - タップ1M: ${_products.any((p) => p.id == tap1M) ? "✅" : "❌"}'); // コメントアウト
      // print('  - タップ100M: ${_products.any((p) => p.id == tap100M) ? "✅" : "❌"}'); // コメントアウト
      
    } catch (e) {
      print('商品読み込み例外: $e');
      print('例外の詳細: ${e.toString()}');
    }
  }

  /// 商品リストを取得
  List<ProductDetails> get products => _products;

  /// デバッグ用：商品情報を詳細に出力
  void debugProducts() {
    print('=== 商品情報デバッグ ===');
    print('読み込み済み商品数: ${_products.length}');
    for (final product in _products) {
      print('商品ID: ${product.id}');
      print('商品名: ${product.title}');
      print('商品説明: ${product.description}');
      print('価格: ${product.price}');
      print('通貨: ${product.currencyCode}');
      print('---');
    }
    print('=== デバッグ終了 ===');
  }

  /// 課金が利用可能か
  bool get isAvailable => _isAvailable;

  /// 商品を購入（実際の課金処理）
  Future<bool> purchaseProduct(ProductDetails product) async {
    try {
      print('=== 購入処理開始 ===');
      print('商品ID: ${product.id}');
      print('商品名: ${product.title}');
      print('商品説明: ${product.description}');
      print('価格: ${product.price}');
      print('通貨: ${product.currencyCode}');
      print('プラットフォーム: ${getPlatformName()}');
      
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      
      bool success = false;
      
      // 商品の種類に応じて適切な購入処理を実行
      if (product.id == removeAds) {
        print('🛒 広告削除の購入処理を開始（非消費型）');
        try {
          success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
          print('広告削除購入結果: $success');
        } catch (e) {
          print('❌ 広告削除購入エラー: $e');
          success = false;
        }
      } else if (product.id == tap10 || product.id == tap100 || product.id == tap1000) {
        print('🛒 タップ倍率商品の購入処理を開始（消費型）: ${product.id}');
        try {
          success = await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
          print('タップ倍率商品購入結果: $success');
        } catch (e) {
          print('❌ タップ倍率商品購入エラー: $e');
          success = false;
        }
      }
      // else if (product.id == tap1M || product.id == tap100M) {
      //   print('🛒 高額タップ倍率商品の購入処理を開始（消費型）: ${product.id}');
      //   try {
      //     success = await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      //     print('高額タップ倍率商品購入結果: $success');
      //   } catch (e) {
      //     print('❌ 高額タップ倍率商品購入エラー: $e');
      //     success = false;
      //   }
      // }

      if (success) {
        print('✅ 購入リクエスト送信成功: ${product.id}');
        // 購入リクエストが成功した場合、購入状態を保存
        await setProductPurchased(product.id);
        print('✅ 購入状態を保存: ${product.id}');
      } else {
        print('❌ 購入リクエスト送信失敗: ${product.id}');
        print('購入リクエストが失敗した理由を確認してください');
        
        // iOS Sandbox環境での追加情報
        if (Platform.isIOS) {
          print('📱 iOS環境での購入失敗');
          print('Sandbox環境でのテストを確認してください:');
          print('1. App Store ConnectでSandboxテスターを設定');
          print('2. デバイスでSandboxアカウントにログイン');
          print('3. アプリを再起動してから購入を試行');
        }
      }

      print('=== 購入処理終了 ===');
      return success;
    } catch (e) {
      print('❌ 購入エラー: $e');
      print('エラーの詳細: ${e.toString()}');
      print('スタックトレース: ${StackTrace.current}');
      return false;
    }
  }

  /// 商品IDからProductDetailsを取得
  ProductDetails? getProductDetails(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      print('商品が見つかりません: $productId');
      return null;
    }
  }

  /// 実際の課金による購入
  Future<bool> purchaseWithRealPayment(String productId) async {
    try {
      print('=== 実際の課金購入開始 ===');
      print('呼び出し元のスタックトレース: ${StackTrace.current}');
      print('商品ID: $productId');
      print('課金利用可能: $_isAvailable');
      print('読み込み済み商品数: ${_products.length}');
      print('プラットフォーム: ${getPlatformName()}');
      
      // 課金が利用可能かチェック
      if (!_isAvailable) {
        print('❌ 課金が利用できません');
        return false;
      }
      
      // 商品が読み込まれているかチェック
      if (_products.isEmpty) {
        print('❌ 商品が読み込まれていません');
        print('商品の再読み込みを試行します...');
        await _loadProducts();
        if (_products.isEmpty) {
          print('❌ 商品の読み込みに失敗しました');
          return false;
        }
      }
      
      final productDetails = getProductDetails(productId);
      if (productDetails == null) {
        print('❌ 商品が見つかりません: $productId');
        print('利用可能な商品: ${_products.map((p) => p.id).toList()}');
        return false;
      }
      
      print('✅ 商品詳細: ${productDetails.id} - ${productDetails.title} - ${productDetails.price}');
      print('商品説明: ${productDetails.description}');
      print('通貨: ${productDetails.currencyCode}');
      
      // 購入前の状態確認
      final isAlreadyPurchased = await isProductPurchased(productId);
      print('既に購入済み: $isAlreadyPurchased');
      
      if (isAlreadyPurchased) {
        print('⚠️ 既に購入済みの商品です');
        return true;
      }
      
      // 高額商品の場合は年齢確認が必要 - 一時的に無効化
      // if (productId == tap1M || productId == tap100M) {
      //   print('高額商品の年齢確認が必要です');
      //   
      //   if (!_isAgeVerified) {
      //     print('❌ 年齢確認なしでの高額商品購入は許可されません');
      //     print('購入画面から年齢確認を行ってください');
      //     return false;
      //   } else {
      //     print('✅ 年齢確認済みです。購入処理を続行します');
      //   }
      // }
      
      final success = await purchaseProduct(productDetails);
      if (success) {
        print('✅ 実際の課金購入リクエスト送信成功: $productId');
      } else {
        print('❌ 実際の課金購入リクエスト送信失敗: $productId');
      }
      
      print('=== 実際の課金購入終了 ===');
      return success;
    } catch (e) {
      print('❌ 実際の課金購入エラー: $e');
      print('エラーの詳細: ${e.toString()}');
      print('スタックトレース: ${StackTrace.current}');
      return false;
    }
  }

  /// 購入履歴を復元
  Future<void> restorePurchases() async {
    try {
      print('購入履歴復元リクエスト送信開始');
      await _inAppPurchase.restorePurchases();
      print('購入履歴復元リクエスト送信完了');
    } catch (e) {
      print('購入履歴復元エラー: $e');
    }
  }

  /// 商品の購入状態を確認
  Future<bool> isProductPurchased(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('purchased_$productId') ?? false;
  }

  /// 商品の購入状態を保存
  Future<void> setProductPurchased(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('purchased_$productId', true);
    print('購入状態を保存: $productId');
  }

  /// 購入状態をクリア（デバッグ用）
  Future<void> clearPurchaseStatus(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('purchased_$productId');
    print('購入状態をクリア: $productId');
  }

  /// タップ倍率を取得
  Future<int> getTapMultiplier() async {
    int multiplier = 1;
    
    // 複数のタップ購入を合計値として計算
    if (await isProductPurchased(tap10)) multiplier += 10;
    if (await isProductPurchased(tap100)) multiplier += 100;
    if (await isProductPurchased(tap1000)) multiplier += 1000;
    // if (await isProductPurchased(tap1M)) multiplier += 1000000; // 100万 - コメントアウト
    // if (await isProductPurchased(tap100M)) multiplier += 100000000; // 1億 - コメントアウト
    
    return multiplier;
  }

  /// バナー広告が削除されているか
  Future<bool> isBannerAdsRemoved() async {
    return await isProductPurchased(removeAds);
  }

  /// 広告が削除されているか（後方互換性のため残す）
  Future<bool> isAdsRemoved() async {
    return await isProductPurchased(removeAds);
  }

  /// 商品の表示名を取得
  String getProductDisplayName(String productId, BuildContext context, {
    String? productRemoveAds,
    String? productTap10,
    String? productTap100,
    String? productTap1000,
    // String? productTap1M, // コメントアウト
    // String? productTap100M, // コメントアウト
    String? productUnknown,
  }) {
    if (productId == removeAds) {
      return productRemoveAds ?? AppLocalizations.of(context)!.purchaseRemoveAds;
    } else if (productId == tap10) {
      return productTap10 ?? AppLocalizations.of(context)!.purchaseTap10;
    } else if (productId == tap100) {
      return productTap100 ?? AppLocalizations.of(context)!.purchaseTap100;
    } else if (productId == tap1000) {
      return productTap1000 ?? AppLocalizations.of(context)!.purchaseTap1000;
    }
    // else if (productId == tap1M) {
    //   return productTap1M ?? '1タップ100万回';
    // } else if (productId == tap100M) {
    //   return productTap100M ?? '1タップ1億回';
    // }
    else {
      return productUnknown ?? '不明な商品';
    }
  }

  /// 商品の価格を取得（実際の商品情報から）
  String getProductPrice(String productId, BuildContext context, {String? priceUnknown}) {
    final productDetails = getProductDetails(productId);
    if (productDetails != null) {
      return productDetails.price;
    }
    
    // ローカライゼーションされた価格を取得
    if (productId == removeAds) {
      return AppLocalizations.of(context)!.priceRemoveAds;
    } else if (productId == tap10) {
      return AppLocalizations.of(context)!.priceTap10;
    } else if (productId == tap100) {
      return AppLocalizations.of(context)!.priceTap100;
    } else if (productId == tap1000) {
      return AppLocalizations.of(context)!.priceTap1000;
    }
    // else if (productId == tap1M) {
    //   return AppLocalizations.of(context)!.priceTap1M;
    // } else if (productId == tap100M) {
    //   return AppLocalizations.of(context)!.priceTap100M;
    // }
    else {
      return priceUnknown ?? AppLocalizations.of(context)!.priceUnknown;
    }
  }

  /// 通貨に応じた価格を取得（数値比較用）
  double getProductPriceValue(String productId, BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    
    if (locale == 'en') {
      // 英語環境（USD）
      if (productId == removeAds) {
        return 0.99;
      } else if (productId == tap10) {
        return 0.99;
      } else if (productId == tap100) {
        return 2.99;
      } else if (productId == tap1000) {
        return 9.99;
      }
      // else if (productId == tap1M) {
      //   return 29.99;
      // } else if (productId == tap100M) {
      //   return 149.99;
      // }
    } else {
      // 日本語環境（JPY）
      if (productId == removeAds) {
        return 100.0;
      } else if (productId == tap10) {
        return 100.0;
      } else if (productId == tap100) {
        return 300.0;
      } else if (productId == tap1000) {
        return 1000.0;
      }
      // else if (productId == tap1M) {
      //   return 30000.0;
      // } else if (productId == tap100M) {
      //   return 150000.0;
      // }
    }
    
    return 9999.0; // 不明な商品は最後に表示
  }

  /// 商品の説明を取得
  String getProductDescription(String productId, BuildContext context, {
    String? descriptionRemoveAds,
    String? descriptionTap10,
    String? descriptionTap100,
    String? descriptionTap1000,
    // String? descriptionTap1M, // コメントアウト
    // String? descriptionTap100M, // コメントアウト
    String? descriptionUnknown,
  }) {
    if (productId == removeAds) {
      return descriptionRemoveAds ?? AppLocalizations.of(context)!.purchaseRemoveAdsDescription;
    } else if (productId == tap10) {
      return descriptionTap10 ?? AppLocalizations.of(context)!.purchaseTap10Description;
    } else if (productId == tap100) {
      return descriptionTap100 ?? AppLocalizations.of(context)!.purchaseTap100Description;
    } else if (productId == tap1000) {
      return descriptionTap1000 ?? AppLocalizations.of(context)!.purchaseTap1000Description;
    }
    // else if (productId == tap1M) {
    //   return descriptionTap1M ?? '1回のタップで100万回分の効果を獲得\n※永久に加算されます';
    // } else if (productId == tap100M) {
    //   return descriptionTap100M ?? '1回のタップで1億回分の効果を獲得\n※永久に加算されます';
    // }
    else {
      return descriptionUnknown ?? '効果不明';
    }
  }

  /// 商品のアイコンを取得
  IconData getProductIcon(String productId) {
    if (productId == removeAds) {
      return Icons.block;
    } else if (productId == tap10) {
      return Icons.flash_on;
    } else if (productId == tap100) {
      return Icons.bolt;
    } else if (productId == tap1000) {
      return Icons.electric_bolt;
    }
    // else if (productId == tap1M) {
    //   return Icons.thunderstorm;
    // } else if (productId == tap100M) {
    //   return Icons.rocket_launch;
    // }
    else {
      return Icons.shopping_cart;
    }
  }

  /// 商品の色を取得
  Color getProductColor(String productId) {
    if (productId == removeAds) {
      return Colors.orange;
    } else if (productId == tap10) {
      return Colors.yellow;
    } else if (productId == tap100) {
      return Colors.orange;
    } else if (productId == tap1000) {
      return Colors.red;
    }
    // else if (productId == tap1M) {
    //   return Colors.purple;
    // } else if (productId == tap100M) {
    //   return Colors.indigo;
    // }
    else {
      return Colors.grey;
    }
  }

  /// プラットフォーム名を取得
  String getPlatformName() {
    return Platform.isIOS ? 'iOS' : 'Android';
  }

  /// 高額商品購入時の年齢確認ダイアログを表示
  Future<bool> showAgeVerificationDialog(BuildContext context, {
    String? title,
    String? content,
    String? yesText,
    String? noText,
  }) async {
    print('年齢確認ダイアログ表示開始');
    
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title ?? 'あなたの年齢選択',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            content ?? 'あそんでいる年齢（ねんれい）によって買（か）える金額（きんがく）がきまっています。\n\n20歳以上ですか？',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                print('「いいえ」ボタンが押されました');
                Navigator.of(context).pop(false);
              },
              child: Text(
                noText ?? 'いいえ',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                print('「はい」ボタンが押されました');
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text(
                yesText ?? 'はい',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    ) ?? false;
    
    // 年齢確認が完了した場合、状態を更新
    if (result) {
      _isAgeVerified = true;
      print('年齢確認状態を更新: $_isAgeVerified');
    }
    
    print('年齢確認ダイアログ結果: $result');
    print('年齢確認ダイアログ表示完了');
    return result;
  }

  /// テスト用：Sandbox環境での購入処理
  Future<bool> testPurchaseInSandbox(String productId) async {
    try {
      print('=== Sandbox環境でのテスト購入開始 ===');
      print('商品ID: $productId');
      print('プラットフォーム: ${getPlatformName()}');
      
      if (!Platform.isIOS) {
        print('❌ Sandbox環境はiOSのみ対応');
        return false;
      }
      
      final productDetails = getProductDetails(productId);
      if (productDetails == null) {
        print('❌ 商品が見つかりません: $productId');
        return false;
      }
      
      print('✅ 商品詳細: ${productDetails.id} - ${productDetails.title} - ${productDetails.price}');
      
      // Sandbox環境での購入処理
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
      bool success = false;
      
      if (productId == removeAds) {
        success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        success = await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      }
      
      print('Sandbox購入結果: $success');
      print('=== Sandbox環境でのテスト購入終了 ===');
      
      return success;
    } catch (e) {
      print('❌ Sandbox購入エラー: $e');
      return false;
    }
  }

  /// デバッグ情報を出力
  void debugPurchaseStatus() async {
    print('=== 購入状態デバッグ ===');
    print('課金利用可能: $_isAvailable');
    print('読み込み済み商品数: ${_products.length}');
    
    for (final productId in [removeAds, tap10, tap100, tap1000]) {
      final isPurchased = await isProductPurchased(productId);
      print('$productId: ${isPurchased ? '購入済み' : '未購入'}');
    }
    print('=== デバッグ終了 ===');
  }
} 