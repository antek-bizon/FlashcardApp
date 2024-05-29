import 'package:flashcards/data/models/quiz_item.dart';
import 'package:flutter/material.dart';

enum ExamItemState { none, correct, wrong }

class ExamItemData {
  ExamItemState state = ExamItemState.none;
  bool answered = false;
}

abstract class ExamItem extends ExamItemData {
  void dispose();
  (bool, String, String)? isAnswerCorrect();
  Widget get widget;
  QuizItemType get type;
  QuizItemBody get data;
  String? get imageUri;
}

class WrongAnswer {
  final String correctAnswer;
  final String userAnswer;
  WrongAnswer({required this.correctAnswer, required this.userAnswer});
}
