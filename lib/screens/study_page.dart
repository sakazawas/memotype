import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

import '../models/study_item.dart';
import '../models/study_mode.dart';
import '../widgets/answer_result_card.dart';
import 'result_page.dart';

// ============================================================
// 学習画面
// ============================================================

class StudyPage extends StatefulWidget {
  const StudyPage({super.key, required this.mode, required this.items});

  final StudyMode mode;
  final List<StudyItem> items;

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  final TextEditingController _answerController = TextEditingController();

  final FocusNode _answerFocusNode = FocusNode();

  final AudioPlayer _audioPlayer = AudioPlayer();

  final Stopwatch _stopwatch = Stopwatch();

  Timer? _timer;

  Duration _elapsed = Duration.zero;

  int _currentIndex = 0;

  int _correctCount = 0;

  int _incorrectCount = 0;

  bool _answered = false;

  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();

    _stopwatch.start();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _elapsed = _stopwatch.elapsed;
      });
    });
  }

  String get _elapsedTimeText {
    final minutes = _elapsed.inMinutes;

    final seconds = _elapsed.inSeconds % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  StudyItem get _currentItem => widget.items[_currentIndex];

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
    _timer?.cancel();
    _stopwatch.stop();

    _answerController.dispose();
    _answerFocusNode.dispose();
    _audioPlayer.dispose();

    super.dispose();
  }

  void _checkAnswer() {
    if (_answered) {
      return;
    }

    final userAnswer = _answerController.text;

    if (userAnswer.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('回答を入力してください。')));

      return;
    }

    final correct = userAnswer == _correctAnswer;

    final isLastQuestion = _currentIndex == widget.items.length - 1;

    if (isLastQuestion) {
      _stopwatch.stop();
      _timer?.cancel();
      _elapsed = _stopwatch.elapsed;
    }

    if (correct) {
      _audioPlayer.play(AssetSource('sounds/correct.mp3'));
    }

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
    final isLastQuestion = _currentIndex >= widget.items.length - 1;

    if (isLastQuestion) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ResultPage(
              mode: widget.mode,
              totalCount: widget.items.length,
              correctCount: _correctCount,
              incorrectCount: _incorrectCount,
              elapsedTime: _elapsed,
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _answerFocusNode.requestFocus();
    });
  }

  Future<bool> _confirmExit() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2B2823),
          title: const Text('学習を終了しますか？'),
          content: const Text('現在の学習結果は保存されません。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('続ける'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('終了'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentIndex + 1) / widget.items.length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }

        final shouldExit = await _confirmExit();

        if (shouldExit && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.mode.title)),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${_currentIndex + 1} / ${widget.items.length}',
                            style: const TextStyle(
                              color: Color(0xFFD8C9AA),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.check_circle_outline,
                          size: 18,
                          color: Color(0xFF9DB2A5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$_correctCount',
                          style: const TextStyle(
                            color: Color(0xFF9DB2A5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: const Color(0xFF3C372F),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFD8C9AA),
                        ),
                      ),
                    ),

                    const SizedBox(height: 34),

                    Text(
                      _elapsedTimeText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFD8C9AA),
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Container(
                      constraints: const BoxConstraints(minHeight: 220),
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B2823),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFF4A4339)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.mode == StudyMode.copyTyping
                                ? '次の文字をそのまま入力'
                                : '次の問題に回答',
                            style: const TextStyle(
                              color: Color(0xFF9E9584),
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 22),

                          SelectableText(
                            _currentItem.question,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFE8DCC3),
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    Focus(
                      onKeyEvent: (node, event) {
                        if (event is KeyDownEvent &&
                            event.logicalKey == LogicalKeyboardKey.enter) {
                          if (_answered) {
                            _nextQuestion();
                          } else {
                            _checkAnswer();
                          }

                          return KeyEventResult.handled;
                        }

                        return KeyEventResult.ignored;
                      },
                      child: TextField(
                        controller: _answerController,
                        focusNode: _answerFocusNode,
                        autofocus: true,
                        readOnly: _answered,
                        maxLines: 4,
                        minLines: 1,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: widget.mode == StudyMode.copyTyping
                              ? '同じ文字を入力'
                              : '答えを入力',
                          prefixIcon: const Icon(Icons.keyboard_outlined),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (!_answered)
                      FilledButton.icon(
                        onPressed: _checkAnswer,
                        icon: const Icon(Icons.check),
                        label: const Text('回答する'),
                      ),

                    if (_answered) ...[
                      AnswerResultCard(
                        isCorrect: _isCorrect,
                        correctAnswer: _correctAnswer,
                      ),

                      const SizedBox(height: 16),

                      FilledButton.icon(
                        onPressed: _nextQuestion,
                        icon: Icon(
                          _currentIndex == widget.items.length - 1
                              ? Icons.flag_outlined
                              : Icons.arrow_forward,
                        ),
                        label: Text(
                          _currentIndex == widget.items.length - 1
                              ? '結果を見る'
                              : '次の問題',
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    const Text(
                      '大文字・小文字、空白、記号も区別して判定します。',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF8E8575), fontSize: 12),
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
