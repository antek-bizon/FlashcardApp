import 'package:flashcards/data/models/quiz_item.dart';
import 'package:flashcards/presentation/widgets/colorful_textfield/colorful_text_editing_controller.dart';

class ClassicFlashcard implements QuizItemBody {
  String question;
  String answer;
  StylesList? styles;

  static const classValue =
      QuizItemId(QuizItemType.classic, "Classic Flashcard");
  static const String _questionEntry = "question";
  static const String _answerEntry = "answer";
  static const String _stylesEntry = "styles";

  ClassicFlashcard({
    required this.question,
    required this.answer,
    this.styles,
  });

  factory ClassicFlashcard.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey(_questionEntry) || !json.containsKey(_answerEntry)) {
      throw "Invalid json data";
    }

    final String question = json[_questionEntry];
    final String answer = json[_answerEntry];
    final StylesList? styles = (json.containsKey(_stylesEntry))
        ? StylesList.fromRanges(
            List<List>.from(json[_stylesEntry] as List), answer.length)
        : null;

    return ClassicFlashcard(question: question, answer: answer, styles: styles);
  }

  factory ClassicFlashcard.copy(ClassicFlashcard item) {
    return ClassicFlashcard(
      question: item.question,
      answer: item.answer,
      styles: item.styles,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {
      _questionEntry: question,
      _answerEntry: answer,
    };

    if (styles != null) {
      map[_stylesEntry] = styles!;
    }

    return map;
  }

  @override
  int get hashCode => Object.hash(question, answer);

  @override
  bool operator ==(Object other) =>
      other is ClassicFlashcard &&
      question == other.question &&
      answer == other.answer;

  @override
  String toString() {
    return "ClassicFlashcard{ question: $question, answer: $answer }";
  }
}
