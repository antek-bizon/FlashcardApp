import 'package:flashcards/data/models/classic_flashcard.dart';
import 'package:flashcards/data/models/one_answer.dart';

class QuizItem {
  String? id;
  String? imageUri;
  QuizItemType type;
  QuizItemBody data;

  QuizItem({required this.data, required this.type, this.id, this.imageUri});

  factory QuizItem.fromJson(
      {required QuizItemType type,
      required Map<String, dynamic> json,
      String? id,
      required String? imageUri}) {
    final QuizItemBody data = _getQuizData(type, json);
    return QuizItem(data: data, type: type, id: id, imageUri: imageUri);
  }

  factory QuizItem.copy(QuizItem item) {
    return QuizItem(
      data: item.data,
      type: item.type,
      imageUri: item.imageUri,
      id: item.id,
    );
  }

  static QuizItemBody _getQuizData(
      QuizItemType type, Map<String, dynamic> json) {
    switch (type) {
      case QuizItemType.classic:
        return ClassicFlashcard.fromJson(json);
      case QuizItemType.oneAnswer:
        return OneAnswer.fromJson(json);
      default:
        throw UnimplementedError("Type $type was not implemented yet");
    }
  }

  @override
  int get hashCode => Object.hash(type, data);

  @override
  bool operator ==(Object other) {
    return other is QuizItem && type == other.type && data == other.data;
  }

  Map<String, dynamic> toJson() {
    return {"type": type.index, "data": data.toJson()};
  }

  @override
  String toString() {
    return "QuizItem{ id: $id, data: $data, imageUri: $imageUri }";
  }
}

enum QuizItemType {
  classic,
  oneAnswer,
}

abstract class QuizItemBody {
  Map<String, dynamic> toJson();

  @override
  int get hashCode;

  @override
  bool operator ==(Object other) => throw UnimplementedError(
      "eq operator must be implemented by the child classes");

  @override
  String toString() {
    throw UnimplementedError(
        "toString must be implemented by the child classes");
  }
}

class QuizItemId {
  final QuizItemType type;
  final String name;
  const QuizItemId(this.type, this.name);

  @override
  int get hashCode => Object.hash(type, name);

  @override
  bool operator ==(Object other) {
    return other is QuizItemId && other.type == type;
  }
}
