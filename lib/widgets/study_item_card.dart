import 'package:flutter/material.dart';

import '../models/study_item.dart';

class StudyItemCard extends StatelessWidget {
  const StudyItemCard({
    super.key,
    required this.number,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final int number;
  final StudyItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        14,
        10,
        14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2823),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF474138),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF3A352D),
            foregroundColor: const Color(0xFFD8C9AA),
            child: Text('$number'),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.question,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFE8DCC3),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.arrow_forward,
                      size: 15,
                      color: Color(0xFF81796B),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.answer,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF9DB2A5),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            iconColor: const Color(0xFFB8AE9A),
            color: const Color(0xFF38332C),
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              } else if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 10),
                      Text('編集'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: Color(0xFFD28C83),
                      ),
                      SizedBox(width: 10),
                      Text(
                        '削除',
                        style: TextStyle(
                          color: Color(0xFFD28C83),
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
}