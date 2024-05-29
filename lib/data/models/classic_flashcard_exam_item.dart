import 'package:flashcards/data/models/classic_flashcard.dart';
import 'package:flashcards/data/models/exam_data.dart';
import 'package:flashcards/data/models/quiz_item.dart';
import 'package:flashcards/presentation/exam_page.dart';
import 'package:flashcards/presentation/widgets/presentation_widget/flashcard_widget.dart';
import 'package:flashcards/utils.dart';
import 'package:flutter/material.dart';

class ClassicFlashcardExamItem extends ExamItemData implements ExamItem {
  ClassicFlashcardExamItem({required this.data, required this.imageUri});
  @override
  final ClassicFlashcard data;
  @override
  final String? imageUri;
  @override
  QuizItemType get type => QuizItemType.classic;
  final _controller = TextEditingController();

  @override
  (bool, String, String)? isAnswerCorrect() {
    final userAnswer = _controller.text;
    if (userAnswer.trim().isEmpty) {
      return null;
    }

    return (userAnswer == data.answer, data.answer, userAnswer);
  }

  @override
  Widget get widget => Column(children: [
        TextFormField(
          controller: _controller,
          enabled: !answered,
          decoration: const InputDecoration(
              hintText: "Answer", contentPadding: EdgeInsets.only(left: 5)),
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return "Please enter some answer";
            }
            return null;
          },
        ),
        addSpacing(height: 25),
        Expanded(
          child: ExamFlashcardWidget(
            item: data,
            imageUri: imageUri,
            showFront: state == ExamItemState.none,
            backColor: state == ExamItemState.wrong
                ? ExamPage.wrongAnswerColor
                : ExamPage.correctAnswerColor,
          ),
        )
      ]);

  @override
  void dispose() {
    _controller.dispose();
  }
}
