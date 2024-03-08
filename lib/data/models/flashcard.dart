class FlashcardModel {
  String question;
  String answer;
  String? imageUri;
  String? id;

  FlashcardModel(
      {required this.question, required this.answer, this.imageUri, this.id});

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
      'image': imageUri ?? "",
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
