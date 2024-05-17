import 'package:flashcards/presentation/widgets/colorful_textfield/colorful_text_editing_controller.dart';

class FlashcardModel {
  String question;
  String answer;
  String? imageUri;
  String? id;
  StylesList? styles;

  FlashcardModel(
      {required this.question,
      required this.answer,
      this.imageUri,
      this.id,
      this.styles});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {
      'question': question,
      'answer': answer,
    };

    if (imageUri != null) {
      map['image'] = imageUri!;
    }

    if (id != null) {
      map['id'] = id!;
    }

    if (styles != null) {
      map['style_list'] = styles!;
    }

    return map;
  }

  @override
  int get hashCode => Object.hash(question, answer);

  @override
  bool operator ==(Object other) =>
      other is FlashcardModel &&
      question == other.question &&
      answer == other.answer;

  @override
  String toString() {
    return "Flashcard: id: $id, question: $question, answer: $answer, image: $imageUri";
  }
}

class FlashcardGroup {
  String? id;
  FlashcardGroup(this.id);

  @override
  String toString() {
    return "FlashcardGroup: $id";
  }
}
