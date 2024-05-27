import 'package:flashcards/data/models/quiz_item.dart';

class OneAnswer implements QuizItemBody {
  String question;
  List<String> answers;
  int correctAnswer;

  static const classValues =
      QuizItemId(QuizItemType.oneAnswer, "One correct answer");
  static const _questionEntry = "question";
  static const _answersEntry = "answers";
  static const _correctAnswerEntry = "correct";

  OneAnswer(
      {required this.question,
      required this.answers,
      required this.correctAnswer});

  factory OneAnswer.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey(_questionEntry) ||
        !json.containsKey(_answersEntry) ||
        !json.containsKey(_correctAnswerEntry)) {
      throw "Invalid json data";
    }

    return OneAnswer(
      question: json[_questionEntry],
      answers: json[_answersEntry],
      correctAnswer: json[_correctAnswerEntry],
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

  @override
  int get hashCode => Object.hash(question, answers);

  @override
  bool operator ==(Object other) =>
      other is OneAnswer &&
      correctAnswer == other.correctAnswer &&
      question == other.question &&
      answers == other.answers;
}
