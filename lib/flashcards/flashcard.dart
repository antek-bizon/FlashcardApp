class Flashcard {
  String question;
  String answer;
  String? image;

  Flashcard({required this.question, required this.answer, this.image});

  Map<String, dynamic> toJson() {
    return {'question': question, 'answer': answer, 'image': image ?? ""};
  }
}
