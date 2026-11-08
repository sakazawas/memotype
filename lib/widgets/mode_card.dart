import 'package:flutter/material.dart';

import '../models/study_mode.dart';

class ModeCard extends StatelessWidget {
  const ModeCard({
    super.key,
    required this.mode,
    required this.example,
    required this.onTap,
  });

  final StudyMode mode;
  final String example;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF2B2823),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF4A4339),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A352D),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  mode.icon,
                  color: const Color(0xFFD8C9AA),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode.title,
                      style: const TextStyle(
                        color: Color(0xFFE8DCC3),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mode.description,
                      style: const TextStyle(
                        color: Color(0xFFAAA18F),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      example,
                      style: const TextStyle(
                        color: Color(0xFF9DB2A5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF978E7E),
              ),
            ],
          ),
        ),
      ),
    );
  }
}