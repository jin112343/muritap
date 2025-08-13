import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:developer' as developer;
import '../services/purchase_service.dart';
import '../config/theme_config.dart';

class PurchaseScreen extends HookWidget {
  const PurchaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = useState(false);
    final selectedProductId = useState<String?>(null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('課金商品'),
        backgroundColor: ThemeConfig.surfaceColor,
        foregroundColor: ThemeConfig.textColor,
      ),
      body: Container(
        color: ThemeConfig.backgroundColor,
        child: Column(
          children: [
            // ヘッダーセクション
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: ThemeConfig.surfaceColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.shopping_cart,
                    size: 60,
                    color: ThemeConfig.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '課金商品',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ThemeConfig.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ゲームをより楽しくする商品を購入できます',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 現在の倍率表示
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: ThemeConfig.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ThemeConfig.primaryColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: FutureBuilder<int>(
                future: PurchaseService.instance.getTapMultiplier(),
                builder: (context, snapshot) {
                  final multiplier = snapshot.data ?? 1;
                  return Row(
                    children: [
                      Icon(
                        Icons.flash_on,
                        color: ThemeConfig.primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '現在のタップ倍率',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: ThemeConfig.primaryColor,
                              ),
                            ),
                            Text(
                              '${multiplier}x',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: ThemeConfig.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 商品リスト
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  // 広告削除
                  _buildProductCard(
                    context,
                    PurchaseService.removeAds,
                    isLoading,
                    selectedProductId,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 1タップ10回
                  _buildProductCard(
                    context,
                    PurchaseService.tap10,
                    isLoading,
                    selectedProductId,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 1タップ100回
                  _buildProductCard(
                    context,
                    PurchaseService.tap100,
                    isLoading,
                    selectedProductId,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 1タップ1000回
                  _buildProductCard(
                    context,
                    PurchaseService.tap1000,
                    isLoading,
                    selectedProductId,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 1タップ100万回
                  _buildProductCard(
                    context,
                    PurchaseService.tap1M,
                    isLoading,
                    selectedProductId,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 1タップ1億回
                  _buildProductCard(
                    context,
                    PurchaseService.tap100M,
                    isLoading,
                    selectedProductId,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 購入履歴復元ボタン
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.restore, color: Colors.blue),
                      title: const Text('購入履歴を復元'),
                      subtitle: const Text('以前の購入を復元します'),
                      onTap: () async {
                        isLoading.value = true;
                        try {
                          await PurchaseService.instance.restorePurchases();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('購入履歴の復元を開始しました'),
                                backgroundColor: Colors.blue,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('復元に失敗しました: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } finally {
                          isLoading.value = false;
                        }
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    String productId,
    ValueNotifier<bool> isLoading,
    ValueNotifier<String?> selectedProductId,
  ) {
    return FutureBuilder<bool>(
      future: PurchaseService.instance.isProductPurchased(productId),
      builder: (context, snapshot) {
        final isPurchased = snapshot.data ?? false;
        
        return Card(
          elevation: 4,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      PurchaseService.instance.getProductIcon(productId),
                      color: isPurchased 
                        ? Colors.green 
                        : PurchaseService.instance.getProductColor(productId),
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            PurchaseService.instance.getProductDisplayName(productId),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ThemeConfig.textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            PurchaseService.instance.getProductDescription(productId),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isPurchased)
                      const Icon(Icons.check_circle, color: Colors.green, size: 24)
                    else
                      Text(
                        PurchaseService.instance.getProductPrice(productId),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ThemeConfig.primaryColor,
                        ),
                      ),
                  ],
                ),
                
                                  if (!isPurchased) ...[
                    const SizedBox(height: 16),
                    // 高額商品の場合は年齢制限の説明を追加
                    if (productId == PurchaseService.tap1M || productId == PurchaseService.tap100M) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.orange,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '20歳以上の方のみ購入可能',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isLoading.value 
                          ? null 
                          : () {
                              developer.log('購入ボタンが押されました: $productId');
                              developer.log('_handlePurchaseWithAgeCheckを呼び出します');
                              _handlePurchaseWithAgeCheck(context, productId, isLoading, selectedProductId);
                            },
                        icon: const Icon(Icons.payment),
                        label: const Text('購入する'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeConfig.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ] else ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                         decoration: BoxDecoration(
                       color: Colors.green.withValues(alpha: 0.1),
                       borderRadius: BorderRadius.circular(8),
                       border: Border.all(color: Colors.green),
                     ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '購入済み',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// 年齢確認を含む購入処理
  Future<void> _handlePurchaseWithAgeCheck(
    BuildContext context,
    String productId,
    ValueNotifier<bool> isLoading,
    ValueNotifier<String?> selectedProductId,
  ) async {
    developer.log('=== _handlePurchaseWithAgeCheck開始 ===');
    developer.log('商品ID: $productId');
    developer.log('高額商品チェック: ${productId == PurchaseService.tap1M || productId == PurchaseService.tap100M}');
    
    // 高額商品（3万円以上）の場合は年齢確認を先に行う
    if (productId == PurchaseService.tap1M || productId == PurchaseService.tap100M) {
      developer.log('=== 高額商品の年齢確認開始 ===');
      developer.log('商品ID: $productId');
      developer.log('tap1M: ${PurchaseService.tap1M}');
      developer.log('tap100M: ${PurchaseService.tap100M}');
      developer.log('商品ID比較結果: ${productId == PurchaseService.tap1M} || ${productId == PurchaseService.tap100M}');
      
      try {
        developer.log('年齢確認ダイアログを表示します');
        developer.log('PurchaseService.instance: ${PurchaseService.instance}');
        developer.log('context: $context');
        developer.log('context.mounted: ${context.mounted}');
        
        // 年齢確認ダイアログの呼び出しをテスト
        developer.log('年齢確認ダイアログ呼び出し開始');
        final isAgeVerified = await PurchaseService.instance.showAgeVerificationDialog(context);
        developer.log('年齢確認ダイアログ呼び出し完了');
        developer.log('年齢確認結果: $isAgeVerified');
        
        if (!isAgeVerified) {
          developer.log('年齢確認が拒否されました');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('年齢確認が完了していないため、購入できません。\n高額商品（3万円以上）は20歳以上の方のみ購入可能です。'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 5),
              ),
            );
          }
          developer.log('年齢確認拒否により購入処理を停止');
          return;
        }
        developer.log('年齢確認が承認されました');
      } catch (e) {
        developer.log('年齢確認ダイアログでエラーが発生: $e');
        developer.log('エラーの詳細: ${e.toString()}');
        developer.log('スタックトレース: ${StackTrace.current}');
        return;
      }
      developer.log('=== 高額商品の年齢確認完了 ===');
    } else {
      developer.log('通常商品のため年齢確認は不要');
      developer.log('商品ID: $productId');
      developer.log('tap1M: ${PurchaseService.tap1M}');
      developer.log('tap100M: ${PurchaseService.tap100M}');
    }
    
    developer.log('年齢確認完了、購入処理を開始します');
    // 年齢確認が完了したら購入処理を実行
    await _purchaseProduct(context, productId, isLoading, selectedProductId);
    developer.log('=== _handlePurchaseWithAgeCheck終了 ===');
  }

    Future<void> _purchaseProduct(
    BuildContext context,
    String productId,
    ValueNotifier<bool> isLoading,
    ValueNotifier<String?> selectedProductId,
  ) async {
    developer.log('=== _purchaseProduct開始 ===');
    developer.log('呼び出し元のスタックトレース: ${StackTrace.current}');
    developer.log('商品ID: $productId');
    developer.log('高額商品チェック: ${productId == PurchaseService.tap1M || productId == PurchaseService.tap100M}');
    
    // 年齢確認は_handlePurchaseWithAgeCheckで既に完了しているため、ここでは行わない
    developer.log('年齢確認は既に完了済みです');
    developer.log('商品ID: $productId');
    developer.log('高額商品ID: ${PurchaseService.tap1M}, ${PurchaseService.tap100M}');
    
    isLoading.value = true;
    selectedProductId.value = productId;
    
    try {
      developer.log('=== 年齢確認後の課金処理開始 ===');
      developer.log('商品ID: $productId');
      
      // 年齢確認が完了した後に購入処理を実行
      // 高額商品の場合は年齢確認済みであることを確認
      if (productId == PurchaseService.tap1M || productId == PurchaseService.tap100M) {
        developer.log('年齢確認済みの高額商品の購入処理を開始');
      }
      
      final success = await PurchaseService.instance.purchaseWithRealPayment(productId);
      
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${PurchaseService.instance.getProductDisplayName(productId)}を購入しました！'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('購入に失敗しました。詳細はコンソールログを確認してください。'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      developer.log('❌ 購入処理でエラーが発生: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('購入エラー: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      isLoading.value = false;
      selectedProductId.value = null;
    }
  }


} 