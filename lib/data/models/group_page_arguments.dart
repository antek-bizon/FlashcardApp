import 'package:flutter/material.dart';

class GroupPageArguments {
  final String groupName;
  // final List<Flashcard> flashcardGroup;
  final VoidCallback onDelete;
  GroupPageArguments(this.groupName, this.onDelete);
}
