import 'package:flutter/material.dart';
import '../config/theme_config.dart';

/// タップボタンウィジェット
/// メインのタップ機能を提供
class TapButton extends StatelessWidget {
  final VoidCallback onTap;
  final AnimationController animationController;
  final bool isProcessing; // 処理中フラグを追加

  const TapButton({
    super.key,
    required this.onTap,
    required this.animationController,
    this.isProcessing = false, // デフォルトはfalse
  });

    @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          final scale = 1.0 + (animationController.value * 0.1);
          
          return Transform.scale(
            scale: scale,
            child: GestureDetector(
              onTapDown: (_) => isProcessing ? null : onTap(), // 処理中は無効
              child: Stack(
                children: [
                  // ベース層（濃い灰色）
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 15,
                          spreadRadius: 3,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                  ),
                  // 中間層（黒）
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  // メインボタン（オレンジ）- 処理中は色を変更
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: isProcessing ? Colors.grey : ThemeConfig.primaryColor,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: (isProcessing ? Colors.grey : ThemeConfig.primaryColor).withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isProcessing)
                            // 処理中はローディングアイコン
                            const SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                strokeWidth: 4,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          else
                            // 通常時はタップアイコン
                            const Icon(
                              Icons.touch_app,
                              size: 60,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 10,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          const SizedBox(height: 8),
                          Text(
                            isProcessing ? '処理中...' : 'Tap',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 8,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 