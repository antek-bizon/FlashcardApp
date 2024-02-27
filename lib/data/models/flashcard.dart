class FlashcardModel {
  String question;
  String answer;
  String? image;
  String? id;

  FlashcardModel(
      {required this.question, required this.answer, this.image, this.id});

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
      'image': image ?? "",
      'id': id ?? ""
    };
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
    return "Flashcard: id: $id, question: $question, answer: $answer, image: $image";
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
