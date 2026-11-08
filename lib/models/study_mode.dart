import 'package:flutter/material.dart';

enum StudyMode {
  copyTyping,
  questionAnswer,
}

extension StudyModeExtension on StudyMode {
  String get title {
    switch (this) {
      case StudyMode.copyTyping:
        return 'そのまま入力';
      case StudyMode.questionAnswer:
        return '問題・回答';
    }
  }

  String get description {
    switch (this) {
      case StudyMode.copyTyping:
        return '表示された文字を、そのまま入力します';
      case StudyMode.questionAnswer:
        return '表示された問題に対応する答えを入力します';
    }
  }

  IconData get icon {
    switch (this) {
      case StudyMode.copyTyping:
        return Icons.keyboard_alt_outlined;
      case StudyMode.questionAnswer:
        return Icons.quiz_outlined;
    }
  }
}