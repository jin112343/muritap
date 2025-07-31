import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart'; // Added for IconData and Color

/// 課金管理サービス
class PurchaseService {
  static final PurchaseService instance = PurchaseService._internal();
  PurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final List<ProductDetails> _products = [];
  bool _isAvailable = false;

  // 商品ID - テスト用IDを使用
  static const String removeAds = 'android.test.purchased'; // テスト用
  static const String tap10 = 'android.test.canceled'; // テスト用
  static const String tap100 = 'android.test.item_unavailable'; // テスト用
  static const String tap1000 = 'android.test.refunded'; // テスト用
  // tap10000は重複を避けるため一時的に無効化
  // static const String tap10000 = 'android.test.canceled'; // テスト用

  /// 課金サービスを初期化
  Future<void> initialize() async {
    _isAvailable = await _inAppPurchase.isAvailable();
    print('課金利用可能: $_isAvailable');
    
    if (_isAvailable) {
      await _loadProducts();
    } else {
      print('課金が利用できません');
    }
    print('課金サービス初期化完了: $_isAvailable');
  }

  /// 商品を読み込み
  Future<void> _loadProducts() async {
    const Set<String> productIds = {
      removeAds,
      tap10,
      tap100,
      tap1000,
    };

    print('商品読み込み開始: $productIds');

    try {
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds);
      
      if (response.notFoundIDs.isNotEmpty) {
        print('見つからない商品ID: ${response.notFoundIDs}');
      }

      if (response.error != null) {
        print('商品読み込みエラー: ${response.error}');
      }

      _products.clear();
      _products.addAll(response.productDetails);
      print('読み込み完了商品数: ${_products.length}');
      
      for (final product in _products) {
        print('商品: ${product.id} - ${product.title} - ${product.price}');
      }
    } catch (e) {
      print('商品読み込み例外: $e');
    }
  }

  /// 商品リストを取得
  List<ProductDetails> get products => _products;

  /// 課金が利用可能か
  bool get isAvailable => _isAvailable;

  /// 商品を購入
  Future<bool> purchaseProduct(ProductDetails product) async {
    try {
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      
      bool success = false;
      switch (product.id) {
        case removeAds:
          success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
          break;
        case tap10:
        case tap100:
        case tap1000:
          success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
          break;
      }

      if (success) {
        print('購入リクエスト送信成功: ${product.id}');
      } else {
        print('購入リクエスト送信失敗: ${product.id}');
      }

      return success;
    } catch (e) {
      print('購入エラー: $e');
      return false;
    }
  }

  /// タップによる購入（課金処理なし）
  Future<bool> purchaseByTap(String productId) async {
    try {
      print('タップ購入開始: $productId');
      
      // 購入状態を保存
      await setProductPurchased(productId);
      
      print('タップ購入完了: $productId');
      return true;
    } catch (e) {
      print('タップ購入エラー: $e');
      return false;
    }
  }

  /// 購入履歴を復元
  Future<void> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
      print('購入履歴復元リクエスト送信');
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

  /// タップ倍率を取得
  Future<int> getTapMultiplier() async {
    int multiplier = 1;
    
    if (await isProductPurchased(tap10)) multiplier = 10;
    if (await isProductPurchased(tap100)) multiplier = 100;
    if (await isProductPurchased(tap1000)) multiplier = 1000;
    
    return multiplier;
  }

  /// 広告が削除されているか
  Future<bool> isAdsRemoved() async {
    return await isProductPurchased(removeAds);
  }

  /// 商品の表示名を取得
  String getProductDisplayName(String productId) {
    switch (productId) {
      case removeAds:
        return '広告削除';
      case tap10:
        return '1タップ10回';
      case tap100:
        return '1タップ100回';
      case tap1000:
        return '1タップ1000回';
      default:
        return '不明な商品';
    }
  }

  /// 商品の価格を取得
  String getProductPrice(String productId) {
    switch (productId) {
      case removeAds:
        return '100円';
      case tap10:
        return '160円';
      case tap100:
        return '300円';
      case tap1000:
        return '3,000円';
      default:
        return '価格不明';
    }
  }

  /// 商品の説明を取得
  String getProductDescription(String productId) {
    switch (productId) {
      case removeAds:
        return 'すべての広告を非表示にします';
      case tap10:
        return '1回のタップで10回分の効果を獲得';
      case tap100:
        return '1回のタップで100回分の効果を獲得';
      case tap1000:
        return '1回のタップで1000回分の効果を獲得';
      default:
        return '効果不明';
    }
  }

  /// 商品のアイコンを取得
  IconData getProductIcon(String productId) {
    switch (productId) {
      case removeAds:
        return Icons.block;
      case tap10:
        return Icons.flash_on;
      case tap100:
        return Icons.bolt;
      case tap1000:
        return Icons.electric_bolt;
      default:
        return Icons.shopping_cart;
    }
  }

  /// 商品の色を取得
  Color getProductColor(String productId) {
    switch (productId) {
      case removeAds:
        return Colors.orange;
      case tap10:
        return Colors.yellow;
      case tap100:
        return Colors.orange;
      case tap1000:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
} 