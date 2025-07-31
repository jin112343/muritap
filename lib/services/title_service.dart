import 'package:flutter/material.dart';

/// 称号管理サービス
class TitleService {
  static final TitleService instance = TitleService._internal();
  TitleService._internal();

  /// レベルに応じた称号を取得
  String getTitle(int level) {
    if (level >= 1000) return "タップ神";
    if (level >= 500) return "タップ仙人";
    if (level >= 200) return "タップマスター";
    if (level >= 100) return "タップ名人";
    if (level >= 50) return "中級者";
    if (level >= 20) return "初級者";
    if (level >= 10) return "初心者";
    if (level >= 5) return "見習い";
    return "新米";
  }

  /// 称号の色を取得
  Color getTitleColor(int level) {
    if (level >= 1000) return Colors.purple;
    if (level >= 500) return Colors.red;
    if (level >= 200) return Colors.orange;
    if (level >= 100) return Colors.yellow;
    if (level >= 50) return Colors.green;
    if (level >= 20) return Colors.blue;
    if (level >= 10) return Colors.cyan;
    if (level >= 5) return Colors.teal;
    return Colors.grey;
  }

  /// 称号のアイコンを取得
  IconData getTitleIcon(int level) {
    if (level >= 1000) return Icons.auto_awesome;
    if (level >= 500) return Icons.star;
    if (level >= 200) return Icons.diamond;
    if (level >= 100) return Icons.workspace_premium;
    if (level >= 50) return Icons.emoji_events;
    if (level >= 20) return Icons.military_tech;
    if (level >= 10) return Icons.sports_esports;
    if (level >= 5) return Icons.school;
    return Icons.person;
  }

  /// 次の称号までのレベルを取得
  int getNextTitleLevel(int currentLevel) {
    if (currentLevel < 5) return 5;
    if (currentLevel < 10) return 10;
    if (currentLevel < 20) return 20;
    if (currentLevel < 50) return 50;
    if (currentLevel < 100) return 100;
    if (currentLevel < 200) return 200;
    if (currentLevel < 500) return 500;
    if (currentLevel < 1000) return 1000;
    return currentLevel; // 最高レベル
  }

  /// 称号の進捗率を計算
  double getTitleProgress(int currentLevel) {
    final nextLevel = getNextTitleLevel(currentLevel);
    if (nextLevel == currentLevel) return 1.0;
    
    final prevLevel = _getPreviousTitleLevel(currentLevel);
    final progress = currentLevel - prevLevel;
    final required = nextLevel - prevLevel;
    
    return progress / required;
  }

  /// 前の称号レベルを取得
  int _getPreviousTitleLevel(int currentLevel) {
    if (currentLevel >= 1000) return 500;
    if (currentLevel >= 500) return 200;
    if (currentLevel >= 200) return 100;
    if (currentLevel >= 100) return 50;
    if (currentLevel >= 50) return 20;
    if (currentLevel >= 20) return 10;
    if (currentLevel >= 10) return 5;
    if (currentLevel >= 5) return 1;
    return 1;
  }
} 