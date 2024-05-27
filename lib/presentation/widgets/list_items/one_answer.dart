import 'package:flashcards/data/models/one_answer.dart';
import 'package:flashcards/data/models/quiz_group.dart';
import 'package:flutter/material.dart';

class OneAnswerListItem extends StatefulWidget {
  final int index;
  final OneAnswer item;
  final QuizGroup group;
  final String? imageUri;
  const OneAnswerListItem({
    super.key,
    required this.index,
    required this.item,
    required this.group,
    required this.imageUri,
  });

  @override
  State<OneAnswerListItem> createState() => _OneAnswerListItemState();
}

class _OneAnswerListItemState extends State<OneAnswerListItem> {
  late TextEditingController _questionField;
  final _scrollController = ScrollController();
  int? _selectedAnswerIndex;
  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _questionField = TextEditingController(text: widget.item.question);
    for (final answer in widget.item.answers) {
      _controllers.add(TextEditingController(text: answer));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
