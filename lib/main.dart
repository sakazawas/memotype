import 'dart:math';

import 'package:flutter/material.dart';

import 'models/study_item.dart';
import 'models/study_mode.dart';
import 'storage/study_storage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MemotypeApp());
}

// ============================================================
// アプリ全体
// ============================================================

class MemotypeApp extends StatelessWidget {
  const MemotypeApp({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF1E1C19);
    const surfaceColor = Color(0xFF2B2823);
    const inputColor = Color(0xFF363129);
    const beigeColor = Color(0xFFD8C9AA);
    const accentColor = Color(0xFF9DB2A5);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Memotype',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: const ColorScheme.dark(
          primary: beigeColor,
          secondary: accentColor,
          surface: surfaceColor,
          error: Color(0xFFD28C83),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundColor,
          foregroundColor: beigeColor,
          centerTitle: true,
          elevation: 0,
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFF4A4339),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: inputColor,
          labelStyle: const TextStyle(
            color: Color(0xFFC1B69F),
          ),
          hintStyle: const TextStyle(
            color: Color(0xFF918878),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF4A4339),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: beigeColor,
              width: 1.5,
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: beigeColor,
            foregroundColor: const Color(0xFF25211C),
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: beigeColor,
            minimumSize: const Size.fromHeight(52),
            side: const BorderSide(
              color: Color(0xFF6B6253),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF494137),
          contentTextStyle: TextStyle(
            color: Color(0xFFF1E7D3),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

// ============================================================
// ホーム画面
// ============================================================

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

// ============================================================
// モード選択カード
// ============================================================

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
        borderRadius:
            BorderRadius.circular(18),
        child: Container(
          padding:
              const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(18),
            border: Border.all(
              color:
                  const Color(0xFF4A4339),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color:
                      const Color(0xFF3A352D),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Icon(
                  mode.icon,
                  color:
                      const Color(0xFFD8C9AA),
                  size: 28,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode.title,
                      style: const TextStyle(
                        color:
                            Color(0xFFE8DCC3),
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mode.description,
                      style: const TextStyle(
                        color:
                            Color(0xFFAAA18F),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      example,
                      style: const TextStyle(
                        color:
                            Color(0xFF9DB2A5),
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color:
                    Color(0xFF978E7E),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 問題一覧カード
// ============================================================

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
      padding:
          const EdgeInsets.fromLTRB(
        16,
        14,
        10,
        14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2823),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              const Color(0xFF474138),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor:
                const Color(0xFF3A352D),
            foregroundColor:
                const Color(0xFFD8C9AA),
            child: Text(
              '$number',
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  item.question,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color:
                        Color(0xFFE8DCC3),
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.arrow_forward,
                      size: 15,
                      color:
                          Color(0xFF81796B),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.answer,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          color:
                              Color(0xFF9DB2A5),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          PopupMenuButton<String>(
            iconColor:
                const Color(0xFFB8AE9A),
            color:
                const Color(0xFF38332C),
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              } else if (value ==
                  'delete') {
                onDelete();
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                      ),
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
                        color:
                            Color(0xFFD28C83),
                      ),
                      SizedBox(width: 10),
                      Text(
                        '削除',
                        style: TextStyle(
                          color:
                              Color(0xFFD28C83),
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

// ============================================================
// 問題なし
// ============================================================

class EmptyItemView extends StatelessWidget {
  const EmptyItemView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2823),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              const Color(0xFF474138),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.library_add_outlined,
            size: 46,
            color:
                Color(0xFF8E8575),
          ),
          SizedBox(height: 12),
          Text(
            '問題が登録されていません',
            style: TextStyle(
              color:
                  Color(0xFFD8C9AA),
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            '「問題を追加」から登録してください。',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color:
                  Color(0xFF9E9584),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 問題追加・編集
// ============================================================

class StudyItemDialog
    extends StatefulWidget {
  const StudyItemDialog({
    super.key,
    this.existingItem,
  });

  final StudyItem? existingItem;

  @override
  State<StudyItemDialog> createState() =>
      _StudyItemDialogState();
}

class _StudyItemDialogState
    extends State<StudyItemDialog> {
  final _formKey =
      GlobalKey<FormState>();

  late final TextEditingController
      _questionController;

  late final TextEditingController
      _answerController;

  @override
  void initState() {
    super.initState();

    _questionController =
        TextEditingController(
      text:
          widget.existingItem?.question ??
              '',
    );

    _answerController =
        TextEditingController(
      text:
          widget.existingItem?.answer ??
              '',
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final item = StudyItem(
      id: widget.existingItem?.id ??
          DateTime.now()
              .microsecondsSinceEpoch
              .toString(),
      question:
          _questionController.text.trim(),
      answer:
          _answerController.text.trim(),
    );

    Navigator.pop(
      context,
      item,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing =
        widget.existingItem != null;

    return AlertDialog(
      backgroundColor:
          const Color(0xFF2B2823),
      title: Text(
        isEditing
            ? '問題を編集'
            : '問題を追加',
      ),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              TextFormField(
                controller:
                    _questionController,
                autofocus: true,
                maxLines: 3,
                minLines: 1,
                decoration:
                    const InputDecoration(
                  labelText:
                      '表示する問題・文字',
                  hintText: '例：Dog',
                  prefixIcon: Icon(
                    Icons.help_outline,
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value
                          .trim()
                          .isEmpty) {
                    return '問題を入力してください。';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller:
                    _answerController,
                maxLines: 3,
                minLines: 1,
                decoration:
                    const InputDecoration(
                  labelText:
                      '問題・回答モードの正答',
                  hintText: '例：犬',
                  prefixIcon: Icon(
                    Icons
                        .check_circle_outline,
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value
                          .trim()
                          .isEmpty) {
                    return '正答を入力してください。';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              const Text(
                'そのまま入力モードでは「表示する問題・文字」が正答になります。',
                style: TextStyle(
                  color:
                      Color(0xFF9E9584),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'キャンセル',
          ),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(
            isEditing
                ? '更新'
                : '追加',
          ),
        ),
      ],
    );
  }
}

// ============================================================
// 学習画面
// ============================================================

class StudyPage extends StatefulWidget {
  const StudyPage({
    super.key,
    required this.mode,
    required this.items,
  });

  final StudyMode mode;
  final List<StudyItem> items;

  @override
  State<StudyPage> createState() =>
      _StudyPageState();
}

class _StudyPageState
    extends State<StudyPage> {
  final TextEditingController
      _answerController =
      TextEditingController();

  final FocusNode _answerFocusNode =
      FocusNode();

  int _currentIndex = 0;

  int _correctCount = 0;

  int _incorrectCount = 0;

  bool _answered = false;

  bool _isCorrect = false;

  StudyItem get _currentItem =>
      widget.items[_currentIndex];

  String get _correctAnswer {
    switch (widget.mode) {
      case StudyMode.copyTyping:
        return _currentItem.question;

      case StudyMode.questionAnswer:
        return _currentItem.answer;
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    _answerFocusNode.dispose();

    super.dispose();
  }

  void _checkAnswer() {
    if (_answered) {
      return;
    }

    final userAnswer =
        _answerController.text;

    if (userAnswer.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            '回答を入力してください。',
          ),
        ),
      );

      return;
    }

    final correct =
        userAnswer == _correctAnswer;

    setState(() {
      _answered = true;
      _isCorrect = correct;

      if (correct) {
        _correctCount++;
      } else {
        _incorrectCount++;
      }
    });
  }

  void _nextQuestion() {
    final isLastQuestion =
        _currentIndex >=
            widget.items.length - 1;

    if (isLastQuestion) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ResultPage(
              mode: widget.mode,
              totalCount:
                  widget.items.length,
              correctCount:
                  _correctCount,
              incorrectCount:
                  _incorrectCount,
            );
          },
        ),
      );

      return;
    }

    setState(() {
      _currentIndex++;
      _answered = false;
      _isCorrect = false;

      _answerController.clear();
    });

    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        _answerFocusNode
            .requestFocus();
      },
    );
  }

  Future<bool> _confirmExit() async {
    final result =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              const Color(0xFF2B2823),
          title: const Text(
            '学習を終了しますか？',
          ),
          content: const Text(
            '現在の学習結果は保存されません。',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child:
                  const Text('続ける'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child:
                  const Text('終了'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        (_currentIndex + 1) /
            widget.items.length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult:
          (didPop, result) async {
        if (didPop) {
          return;
        }

        final shouldExit =
            await _confirmExit();

        if (shouldExit &&
            context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title:
              Text(widget.mode.title),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  maxWidth: 720,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${_currentIndex + 1} / ${widget.items.length}',
                            style:
                                const TextStyle(
                              color:
                                  Color(
                                0xFFD8C9AA,
                              ),
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons
                              .check_circle_outline,
                          size: 18,
                          color:
                              Color(
                            0xFF9DB2A5,
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          '$_correctCount',
                          style:
                              const TextStyle(
                            color:
                                Color(
                              0xFF9DB2A5,
                            ),
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    ClipRRect(
                      borderRadius:
                          BorderRadius
                              .circular(100),
                      child:
                          LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor:
                            const Color(
                          0xFF3C372F,
                        ),
                        valueColor:
                            const AlwaysStoppedAnimation<
                                Color>(
                          Color(
                            0xFFD8C9AA,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 34,
                    ),

                    Container(
                      constraints:
                          const BoxConstraints(
                        minHeight: 220,
                      ),
                      padding:
                          const EdgeInsets
                              .all(26),
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFF2B2823,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          22,
                        ),
                        border:
                            Border.all(
                          color:
                              const Color(
                            0xFF4A4339,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          Text(
                            widget.mode ==
                                    StudyMode
                                        .copyTyping
                                ? '次の文字をそのまま入力'
                                : '次の問題に回答',
                            style:
                                const TextStyle(
                              color:
                                  Color(
                                0xFF9E9584,
                              ),
                              fontSize:
                                  14,
                            ),
                          ),

                          const SizedBox(
                            height: 22,
                          ),

                          SelectableText(
                            _currentItem
                                .question,
                            textAlign:
                                TextAlign
                                    .center,
                            style:
                                const TextStyle(
                              color:
                                  Color(
                                0xFFE8DCC3,
                              ),
                              fontSize:
                                  34,
                              fontWeight:
                                  FontWeight
                                      .bold,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    TextField(
                      controller:
                          _answerController,
                      focusNode:
                          _answerFocusNode,
                      autofocus: true,
                      enabled:
                          !_answered,
                      maxLines: 4,
                      minLines: 1,
                      textInputAction:
                          TextInputAction
                              .done,
                      onSubmitted: (_) {
                        if (!_answered) {
                          _checkAnswer();
                        }
                      },
                      decoration:
                          InputDecoration(
                        labelText: widget
                                    .mode ==
                                StudyMode
                                    .copyTyping
                            ? '同じ文字を入力'
                            : '答えを入力',
                        prefixIcon:
                            const Icon(
                          Icons
                              .keyboard_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    if (!_answered)
                      FilledButton.icon(
                        onPressed:
                            _checkAnswer,
                        icon:
                            const Icon(
                          Icons.check,
                        ),
                        label:
                            const Text(
                          '回答する',
                        ),
                      ),

                    if (_answered) ...[
                      AnswerResultCard(
                        isCorrect:
                            _isCorrect,
                        correctAnswer:
                            _correctAnswer,
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      FilledButton.icon(
                        onPressed:
                            _nextQuestion,
                        icon: Icon(
                          _currentIndex ==
                                  widget.items
                                          .length -
                                      1
                              ? Icons
                                  .flag_outlined
                              : Icons
                                  .arrow_forward,
                        ),
                        label: Text(
                          _currentIndex ==
                                  widget.items
                                          .length -
                                      1
                              ? '結果を見る'
                              : '次の問題',
                        ),
                      ),
                    ],

                    const SizedBox(
                      height: 14,
                    ),

                    const Text(
                      '大文字・小文字、空白、記号も区別して判定します。',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        color:
                            Color(
                          0xFF8E8575,
                        ),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 回答結果
// ============================================================

class AnswerResultCard
    extends StatelessWidget {
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
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:
            color.withValues(alpha: 0.12),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              color.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
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
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),

          if (!isCorrect) ...[
            const SizedBox(height: 12),

            const Text(
              '正答',
              style: TextStyle(
                color:
                    Color(0xFF9E9584),
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 4),

            SelectableText(
              correctAnswer,
              style: const TextStyle(
                color:
                    Color(0xFFE8DCC3),
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// 結果画面
// ============================================================

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
    final percentage =
        (correctRate * 100).round();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:
            const Text('学習結果'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 600,
              ),
              child: Column(
                children: [
                  Container(
                    width: 116,
                    height: 116,
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFF2B2823,
                      ),
                      shape:
                          BoxShape.circle,
                      border:
                          Border.all(
                        color:
                            const Color(
                          0xFFD8C9AA,
                        ),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$percentage%',
                        style:
                            const TextStyle(
                          color:
                              Color(
                            0xFFE8DCC3,
                          ),
                          fontSize: 30,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 22,
                  ),

                  Text(
                    message,
                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xFFD8C9AA,
                      ),
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    mode.title,
                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xFF9E9584,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  Container(
                    padding:
                        const EdgeInsets
                            .all(22),
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFF2B2823,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        20,
                      ),
                      border:
                          Border.all(
                        color:
                            const Color(
                          0xFF474138,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        ResultRow(
                          label: '問題数',
                          value:
                              '$totalCount',
                          color:
                              const Color(
                            0xFFD8C9AA,
                          ),
                        ),

                        const Divider(
                          height: 28,
                        ),

                        ResultRow(
                          label: '正解',
                          value:
                              '$correctCount',
                          color:
                              const Color(
                            0xFF9DB2A5,
                          ),
                        ),

                        const Divider(
                          height: 28,
                        ),

                        ResultRow(
                          label: '不正解',
                          value:
                              '$incorrectCount',
                          color:
                              const Color(
                            0xFFD28C83,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 26,
                  ),

                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
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

// ============================================================
// 結果行
// ============================================================

class ResultRow
    extends StatelessWidget {
  const ResultRow({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;

  final String value;

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style:
                const TextStyle(
              color:
                  Color(0xFFB6AC99),
              fontSize: 16,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ],
    );
  }
}