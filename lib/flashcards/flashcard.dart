class Flashcard {
  String question;
  String answer;
  String? image;
  String? id;

  Flashcard(
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
      other is Flashcard &&
      question == other.question &&
      answer == other.answer;
}

class FlashcardGroupOptions {
  final String? id;
  FlashcardGroupOptions({this.id});
}
