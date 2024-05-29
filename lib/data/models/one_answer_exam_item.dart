import 'package:flashcards/data/models/exam_data.dart';
import 'package:flashcards/data/models/one_answer.dart';
import 'package:flashcards/data/models/quiz_item.dart';
import 'package:flashcards/presentation/widgets/presentation_widget/one_answer_widget.dart';
import 'package:flutter/material.dart';

class OneAnswerExamItem extends ExamItemData implements ExamItem {
  OneAnswerExamItem({required this.data, required this.imageUri});
  @override
  final OneAnswer data;
  @override
  final String? imageUri;
  @override
  QuizItemType get type => QuizItemType.oneAnswer;

  int? _selectedAnswerIndex;
  @override
  (bool, String, String)? isAnswerCorrect() {
    if (_selectedAnswerIndex == null) {
      return null;
    }

    return (
      _selectedAnswerIndex == data.correctAnswer,
      String.fromCharCode(65 + data.correctAnswer),
      String.fromCharCode(65 + _selectedAnswerIndex!)
    );
  }

  @override
  Widget get widget => ExamOneAnswerWidget(
        item: data,
        imageUri: imageUri,
        showFront: _selectedAnswerIndex == null,
        selectedAnswerIndex: _selectedAnswerIndex,
        onRadio: (index) {
          _selectedAnswerIndex = index;
        },
      );

  @override
  void dispose() {}
}
