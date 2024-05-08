import 'package:flashcards/presentation/widgets/rich_text_editor/src/spannable_list.dart';

class FlashcardModel {
  String question;
  String answer;
  String? imageUri;
  String? id;
  SpannableList? styleList;

  FlashcardModel(
      {required this.question,
      required this.answer,
      this.imageUri,
      this.id,
      this.styleList});

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

    if (styleList != null) {
      map['style_list'] = styleList!;
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
