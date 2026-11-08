import 'package:flutter/material.dart';

class AnswerResultCard extends StatelessWidget {
  const AnswerResultCard({
    super.key,
    required this.isCorrect,
    required this.correctAnswer,
  });

  final bool isCorrect;
  final String correctAnswer;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect
        ? const Color(0xFF9DB2A5)
        : const Color(0xFFD28C83);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect
                    ? Icons.check_circle
                    : Icons.cancel,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect
                    ? '正解です'
                    : '不正解です',
                style: TextStyle(
                  color: color,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 12),
            const Text(
              '正答',
              style: TextStyle(
                color: Color(0xFF9E9584),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            SelectableText(
              correctAnswer,
              style: const TextStyle(
                color: Color(0xFFE8DCC3),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}