import 'package:flashcards/data/models/one_answer.dart';
import 'package:flashcards/presentation/exam_page.dart';
import 'package:flashcards/presentation/widgets/presentation_widget/quiz_item_widget.dart';
import 'package:flutter/material.dart';

class OneAnswerWidget extends StatefulWidget {
  const OneAnswerWidget({
    super.key,
    required this.item,
    required this.imageUri,
  });
  final OneAnswer item;
  final String? imageUri;

  @override
  State<OneAnswerWidget> createState() => _OneAnswerWidgetState();
}

class _OneAnswerWidgetState extends State<OneAnswerWidget> {
  int? _selectedAnswerIndex;

  bool get _showFront => _selectedAnswerIndex == null;

  void _onRadio(int? index) {
    if (index != null) {
      setState(() {
        _selectedAnswerIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExamOneAnswerWidget(
      item: widget.item,
      imageUri: widget.imageUri,
      showFront: _showFront,
      selectedAnswerIndex: _selectedAnswerIndex,
      onRadio: _onRadio,
    );
  }
}

class ExamOneAnswerWidget extends StatefulWidget {
  const ExamOneAnswerWidget({
    super.key,
    required this.item,
    required this.imageUri,
    required this.showFront,
    required this.selectedAnswerIndex,
    required this.onRadio,
  });
  final OneAnswer item;
  final String? imageUri;
  final int? selectedAnswerIndex;
  final void Function(int?) onRadio;
  final bool showFront;

  @override
  State<ExamOneAnswerWidget> createState() => _ExamOneAnswerWidgetState();
}

class _ExamOneAnswerWidgetState extends State<ExamOneAnswerWidget> {
  int? _radioIndex;

  Color? _backColor() {
    if (widget.selectedAnswerIndex == null) {
      return null;
    }

    if (widget.selectedAnswerIndex == widget.item.correctAnswer) {
      return ExamPage.correctAnswerColor;
    }

    return ExamPage.wrongAnswerColor;
  }

  IconData _icon(int listIndex) {
    if (listIndex == widget.item.correctAnswer) {
      return Icons.check;
    }
    if (listIndex == widget.selectedAnswerIndex) {
      return Icons.close;
    }
    return Icons.crop_din_rounded;
  }

  Widget _radio(int listIndex) {
    if (widget.showFront) {
      return Radio<int>(
        value: listIndex,
        groupValue: _radioIndex,
        onChanged: (index) {
          setState(() {
            _radioIndex = index;
          });
          widget.onRadio(index);
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Icon(_icon(listIndex)),
    );
  }

  @override
  Widget build(BuildContext context) {
    _radioIndex = widget.selectedAnswerIndex ?? _radioIndex;

    return QuizItemWidget(
      imageUri: widget.imageUri,
      showFront: widget.showFront,
      title: widget.item.question,
      backColor: _backColor(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: AnswerList(
          length: widget.item.answers.length,
          builder: (index) => [
            _radio(index),
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Text(widget.item.answers[index]),
            ),
          ],
        ),
      ),
    );
  }
}

class AnswerList extends StatelessWidget {
  const AnswerList({
    super.key,
    required this.length,
    required this.builder,
  });
  final int length;
  final List<Widget> Function(int) builder;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.3),
      child: ListView.builder(
        itemCount: length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: builder(index),
            ),
          );
        },
      ),
    );
  }
}
