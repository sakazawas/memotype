import 'package:flutter/material.dart';

import '../models/study_mode.dart';
import '../widgets/result_row.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({
    super.key,
    required this.mode,
    required this.totalCount,
    required this.correctCount,
    required this.incorrectCount,
  });

  final StudyMode mode;
  final int totalCount;
  final int correctCount;
  final int incorrectCount;

  double get correctRate {
    if (totalCount == 0) {
      return 0;
    }

    return correctCount / totalCount;
  }

  String get message {
    if (correctRate == 1) {
      return '全問正解です';
    }

    if (correctRate >= 0.8) {
      return 'よくできました';
    }

    if (correctRate >= 0.5) {
      return 'もう少しです';
    }

    return '繰り返し練習しましょう';
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (correctRate * 100).round();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('学習結果'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              child: Column(
                children: [
                  Container(
                    width: 116,
                    height: 116,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B2823),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFD8C9AA),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$percentage%',
                        style: const TextStyle(
                          color: Color(0xFFE8DCC3),
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Color(0xFFD8C9AA),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mode.title,
                    style: const TextStyle(
                      color: Color(0xFF9E9584),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B2823),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF474138),
                      ),
                    ),
                    child: Column(
                      children: [
                        ResultRow(
                          label: '問題数',
                          value: '$totalCount',
                          color: const Color(0xFFD8C9AA),
                        ),
                        const Divider(height: 28),
                        ResultRow(
                          label: '正解',
                          value: '$correctCount',
                          color: const Color(0xFF9DB2A5),
                        ),
                        const Divider(height: 28),
                        ResultRow(
                          label: '不正解',
                          value: '$incorrectCount',
                          color: const Color(0xFFD28C83),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.home_outlined,
                    ),
                    label: const Text(
                      'ホームに戻る',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}