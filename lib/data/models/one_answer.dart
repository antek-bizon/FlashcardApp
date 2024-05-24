import 'package:flashcards/data/models/quiz_item.dart';

class OneAnswer implements QuizItemBody {
  String question;
  List<String> answers;
  int correctAnswer;

  static const String _questionEntry = "question";
  static const String _answersEntry = "answers";
  static const String _correctAnswerEntry = "correct";

  OneAnswer(
      {required this.question,
      required this.answers,
      required this.correctAnswer});

  factory OneAnswer.fromJson(Map<String, dynamic> json) {
    return OneAnswer(
      question: "question",
      answers: ["answers"],
      correctAnswer: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      _questionEntry: question,
      _answersEntry: answers,
      _correctAnswerEntry: correctAnswer
    };
  }
}
