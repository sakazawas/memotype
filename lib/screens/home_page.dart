import 'dart:math';

import 'package:flutter/material.dart';

import '../dialogs/study_item_dialog.dart';
import '../models/study_item.dart';
import '../models/study_mode.dart';
import '../storage/study_storage.dart';
import '../widgets/empty_item_view.dart';
import '../widgets/mode_card.dart';
import '../widgets/study_item_card.dart';
import 'study_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final StudyStorage _storage = StudyStorage();

  List<StudyItem> _items = [];

  bool _isLoading = true;
  bool _shuffleQuestions = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final loadedItems = await _storage.loadItems();

    if (!mounted) {
      return;
    }

    setState(() {
      _items = loadedItems;
      _isLoading = false;
    });
  }

  Future<void> _saveItems() async {
    await _storage.saveItems(_items);
  }

  Future<void> _openItemEditor({
    StudyItem? existingItem,
  }) async {
    final result = await showDialog<StudyItem>(
      context: context,
      builder: (context) {
        return StudyItemDialog(
          existingItem: existingItem,
        );
      },
    );

    if (result == null) {
      return;
    }

    setState(() {
      if (existingItem == null) {
        _items.add(result);
      } else {
        final index = _items.indexWhere(
          (item) => item.id == existingItem.id,
        );

        if (index != -1) {
          _items[index] = result;
        }
      }
    });

    await _saveItems();
  }

  Future<void> _deleteItem(StudyItem item) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2B2823),
          title: const Text(
            '問題を削除しますか？',
          ),
          content: Text(
            '「${item.question}」を削除します。',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'キャンセル',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor:
                    const Color(0xFFD28C83),
              ),
              child: const Text(
                '削除',
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    setState(() {
      _items.removeWhere(
        (target) => target.id == item.id,
      );
    });

    await _saveItems();
  }

  void _startStudy(StudyMode mode) {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '先に問題を1件以上登録してください。',
          ),
        ),
      );

      return;
    }

    final studyItems =
        List<StudyItem>.from(_items);

    if (_shuffleQuestions) {
      studyItems.shuffle(Random());
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return StudyPage(
            mode: mode,
            items: studyItems,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Memotype',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          _openItemEditor();
        },
        backgroundColor:
            const Color(0xFFD8C9AA),
        foregroundColor:
            const Color(0xFF25211C),
        icon: const Icon(
          Icons.add,
        ),
        label: const Text(
          '問題を追加',
        ),
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            100,
          ),
          children: [
            const Text(
              '学習モード',
              style: TextStyle(
                color: Color(0xFFD8C9AA),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              '学習方法を選択してください。',
              style: TextStyle(
                color: Color(0xFFAAA18F),
              ),
            ),

            const SizedBox(height: 18),

            ModeCard(
              mode: StudyMode.copyTyping,
              example: 'Dog  →  Dog',
              onTap: () {
                _startStudy(
                  StudyMode.copyTyping,
                );
              },
            ),

            const SizedBox(height: 12),

            ModeCard(
              mode:
                  StudyMode.questionAnswer,
              example: 'Dog  →  犬',
              onTap: () {
                _startStudy(
                  StudyMode.questionAnswer,
                );
              },
            ),

            const SizedBox(height: 18),

            // =====================================
            // 修正箇所
            // Container自体には背景色を設定せず、
            // Materialを背景として使用
            // =====================================

            Material(
              color: const Color(0xFF2B2823),
              borderRadius:
                  BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        const Color(0xFF474138),
                  ),
                ),
                child: SwitchListTile(
                  value: _shuffleQuestions,
                  onChanged: (value) {
                    setState(() {
                      _shuffleQuestions =
                          value;
                    });
                  },
                  activeTrackColor:
                      const Color(0xFF9DB2A5),
                  title: const Text(
                    '問題をシャッフル',
                  ),
                  subtitle: const Text(
                    '学習開始時に問題の順番を変更します',
                    style: TextStyle(
                      color:
                          Color(0xFF9E9584),
                    ),
                  ),
                  secondary: const Icon(
                    Icons.shuffle,
                    color:
                        Color(0xFFD8C9AA),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                const Expanded(
                  child: Text(
                    '登録済みの問題',
                    style: TextStyle(
                      color:
                          Color(0xFFD8C9AA),
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${_items.length}件',
                  style: const TextStyle(
                    color:
                        Color(0xFFAAA18F),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (_items.isEmpty)
              const EmptyItemView()
            else
              ...List.generate(
                _items.length,
                (index) {
                  final item =
                      _items[index];

                  return Padding(
                    padding:
                        const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: StudyItemCard(
                      number: index + 1,
                      item: item,
                      onEdit: () {
                        _openItemEditor(
                          existingItem: item,
                        );
                      },
                      onDelete: () {
                        _deleteItem(item);
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}