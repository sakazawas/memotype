import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/study_record.dart';

class StudyRecordStorage {
  static const _recordsKey = 'study_records';

  Future<List<StudyRecord>> loadRecords() async {
    final preferences =
        await SharedPreferences.getInstance();

    final savedRecords =
        preferences.getStringList(_recordsKey) ?? [];

    return savedRecords.map((record) {
      final json =
          jsonDecode(record) as Map<String, dynamic>;

      return StudyRecord.fromJson(json);
    }).toList();
  }

  Future<void> addRecord(
    StudyRecord record,
  ) async {
    final preferences =
        await SharedPreferences.getInstance();

    final records = await loadRecords();

    records.add(record);

    final encodedRecords = records.map((item) {
      return jsonEncode(item.toJson());
    }).toList();

    await preferences.setStringList(
      _recordsKey,
      encodedRecords,
    );
  }
}