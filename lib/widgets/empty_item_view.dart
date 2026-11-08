import 'package:flutter/material.dart';

class EmptyItemView extends StatelessWidget {
  const EmptyItemView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2823),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF474138),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.library_add_outlined,
            size: 46,
            color: Color(0xFF8E8575),
          ),
          SizedBox(height: 12),
          Text(
            '問題が登録されていません',
            style: TextStyle(
              color: Color(0xFFD8C9AA),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            '「問題を追加」から登録してください。',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF9E9584),
            ),
          ),
        ],
      ),
    );
  }
}