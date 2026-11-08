import 'package:flutter/material.dart';

import '../models/study_item.dart';

class StudyItemDialog extends StatefulWidget {
  const StudyItemDialog({
    super.key,
    this.existingItem,
  });

  final StudyItem? existingItem;

  @override
  State<StudyItemDialog> createState() =>
      _StudyItemDialogState();
}

class _StudyItemDialogState extends State<StudyItemDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _questionController;
  late final TextEditingController _answerController;

  @override
  void initState() {
    super.initState();

    _questionController = TextEditingController(
      text: widget.existingItem?.question ?? '',
    );

    _answerController = TextEditingController(
      text: widget.existingItem?.answer ?? '',
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final item = StudyItem(
      id: widget.existingItem?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      question: _questionController.text.trim(),
      answer: _answerController.text.trim(),
    );

    Navigator.pop(
      context,
      item,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingItem != null;

    return AlertDialog(
      backgroundColor: const Color(0xFF2B2823),
      title: Text(
        isEditing ? '問題を編集' : '問題を追加',
      ),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _questionController,
                autofocus: true,
                maxLines: 3,
                minLines: 1,
                decoration: const InputDecoration(
                  labelText: '表示する問題・文字',
                  hintText: '例：Dog',
                  prefixIcon: Icon(
                    Icons.help_outline,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '問題を入力してください。';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _answerController,
                maxLines: 3,
                minLines: 1,
                decoration: const InputDecoration(
                  labelText: '問題・回答モードの正答',
                  hintText: '例：犬',
                  prefixIcon: Icon(
                    Icons.check_circle_outline,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '正答を入力してください。';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              const Text(
                'そのまま入力モードでは「表示する問題・文字」が正答になります。',
                style: TextStyle(
                  color: Color(0xFF9E9584),
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
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(
            isEditing ? '更新' : '追加',
          ),
        ),
      ],
    );
  }
}