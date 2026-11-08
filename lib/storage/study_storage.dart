import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/study_item.dart';

class StudyStorage {
  static const String _storageKey = 'memotype_study_items_v2';

  final SharedPreferencesAsync _preferences =
      SharedPreferencesAsync();

  Future<List<StudyItem>> loadItems() async {
    try {
      final savedData =
          await _preferences.getString(_storageKey);

      if (savedData == null || savedData.isEmpty) {
        return _defaultItems;
      }

      final decoded = jsonDecode(savedData);

      if (decoded is! List) {
        return _defaultItems;
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) => StudyItem.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .where(
            (item) =>
                item.question.trim().isNotEmpty &&
                item.answer.trim().isNotEmpty,
          )
          .toList();
    } catch (_) {
      return _defaultItems;
    }
  }

  Future<void> saveItems(List<StudyItem> items) async {
    final encoded = jsonEncode(
      items.map((item) => item.toJson()).toList(),
    );

    await _preferences.setString(
      _storageKey,
      encoded,
    );
  }

  List<StudyItem> get _defaultItems {
    return const [
      StudyItem(
        id: 'sample-1',
        question: 'Dog',
        answer: '犬',
      ),
      StudyItem(
        id: 'sample-2',
        question: 'Cat',
        answer: '猫',
      ),
      StudyItem(
        id: 'sample-3',
        question: 'Apple',
        answer: 'りんご',
      ),
    ];
  }
}