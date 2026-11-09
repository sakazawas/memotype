import 'package:flutter/material.dart';

import '../models/study_mode.dart';
import '../models/study_record.dart';
import '../storage/study_record_storage.dart';
import '../widgets/result_row.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({
    super.key,
    required this.mode,
    required this.totalCount,
    required this.correctCount,
    required this.incorrectCount,
    required this.elapsedTime,
  });

  final StudyMode mode;
  final int totalCount;
  final int correctCount;
  final int incorrectCount;
  final Duration elapsedTime;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final StudyRecordStorage _storage = StudyRecordStorage();

  List<StudyRecord> _records = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _saveAndLoadRecords();
  }

  List<StudyRecord> get highScores {
    final records = List<StudyRecord>.from(_records);

    records.sort((a, b) {
      final correctComparison = b.correctCount.compareTo(a.correctCount);

      if (correctComparison != 0) {
        return correctComparison;
      }

      return a.elapsedSeconds.compareTo(b.elapsedSeconds);
    });

    return records.take(5).toList();
  }

  Future<void> _saveAndLoadRecords() async {
    final currentRecord = StudyRecord(
      correctCount: widget.correctCount,
      totalCount: widget.totalCount,
      elapsedSeconds: widget.elapsedTime.inSeconds,
    );

    await _storage.addRecord(currentRecord);

    final loadedRecords = await _storage.loadRecords();

    if (!mounted) {
      return;
    }

    setState(() {
      _records = loadedRecords;
      _isLoading = false;
    });
  }

  double get correctRate {
    if (widget.totalCount == 0) {
      return 0;
    }

    return widget.correctCount / widget.totalCount;
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
              constraints: const BoxConstraints(maxWidth: 600),
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
                    widget.mode.title,
                    style: const TextStyle(color: Color(0xFF9E9584)),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B2823),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF474138)),
                    ),
                    child: Column(
                      children: [
                        ResultRow(
                          label: '問題数',
                          value: '${widget.totalCount}',
                          color: const Color(0xFFD8C9AA),
                        ),
                        const Divider(height: 28),
                        ResultRow(
                          label: '正解',
                          value: '${widget.correctCount}',
                          color: const Color(0xFF9DB2A5),
                        ),
                        const Divider(height: 28),
                        ResultRow(
                          label: '不正解',
                          value: '${widget.incorrectCount}',
                          color: const Color(0xFFD28C83),
                        ),
                        const Divider(height: 28),
                        ResultRow(
                          label: '学習時間',
                          value:
                              '${widget.elapsedTime.inMinutes}:${(widget.elapsedTime.inSeconds % 60).toString().padLeft(2, '0')}',
                          color: const Color(0xFFD8C9AA),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),

                  if (!_isLoading) ...[
                    const Text(
                      'ハイスコア',
                      style: TextStyle(
                        color: Color(0xFFD8C9AA),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Row(
                      children: [
                        Expanded(
                          child: Text(
                            '順位',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Color(0xFF9E9584),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '正答数',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF9E9584),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '時間',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Color(0xFF9E9584),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 20),

                    ...List.generate(highScores.length, (index) {
                      final record = highScores[index];

                      final minutes = record.elapsedSeconds ~/ 60;
                      final seconds = record.elapsedSeconds % 60;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${index + 1}位',
                                style: const TextStyle(
                                  color: Color(0xFFD8C9AA),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${record.correctCount} / ${record.totalCount}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF9DB2A5),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '$minutes:${seconds.toString().padLeft(2, '0')}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: Color(0xFFD8C9AA),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 24),
                  ],

                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.home_outlined),
                    label: const Text('ホームに戻る'),
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
