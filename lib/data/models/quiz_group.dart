class QuizGroup {
  final String name;
  String? id;
  QuizGroup({required this.name, this.id});

  bool get hasId => id != null;

  @override
  int get hashCode => Object.hash(name, id);

  @override
  operator ==(Object other) {
    return other is QuizGroup && name == other.name;
  }
}
