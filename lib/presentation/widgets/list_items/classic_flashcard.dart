import 'package:flashcards/data/models/classic_flashcard.dart';
import 'package:flashcards/data/models/quiz_group.dart';
import 'package:flashcards/presentation/widgets/colorful_textfield/colorful_text_editing_controller.dart';
import 'package:flashcards/presentation/widgets/colorful_textfield/text_field_toolbar.dart';
import 'package:flashcards/presentation/widgets/list_items/quiz_list_item.dart';
import 'package:flashcards/presentation/widgets/multi_line_text_field.dart';
import 'package:flutter/material.dart';

class ClassicFlashcardListItem extends StatefulWidget {
  const ClassicFlashcardListItem({
    super.key,
    required this.index,
    required this.flashcard,
    required this.group,
    required this.imageUri,
  });

  final int index;
  final ClassicFlashcard flashcard;
  final QuizGroup group;
  final String? imageUri;

  @override
  State<ClassicFlashcardListItem> createState() =>
      _ClassicFlashcardListItemState();
}

class _ClassicFlashcardListItemState extends State<ClassicFlashcardListItem> {
  bool _editable = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _questionField;
  late ColorfulTextEditingController _answerField;

  @override
  void initState() {
    _questionField = TextEditingController(text: widget.flashcard.question);
    _answerField = ColorfulTextEditingController(
        text: widget.flashcard.answer, styles: widget.flashcard.styles);
    super.initState();
  }

  @override
  void dispose() {
    _questionField.dispose();
    _answerField.dispose();
    super.dispose();
  }

  bool _onEdit(bool wasEditable) {
    if (wasEditable && _formKey.currentState!.validate()) {
      setState(() {
        widget.flashcard.question = _questionField.text;
        widget.flashcard.answer = _answerField.text;
        widget.flashcard.styles = _answerField.styles;

        _editable = false;
      });
      return false;
    }
    if (!_editable) {
      setState(() {
        _editable = true;
      });
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    _answerField.setDefaultColor(Theme.of(context).colorScheme.onSurface);

    return QuizListItemBody(
        index: widget.index,
        group: widget.group,
        imageUri: widget.imageUri,
        onEdit: _onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 1.0),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Column(
                children: [
                  MultiLineTextField(
                      controller: _questionField,
                      enabled: _editable,
                      hintText: "Question",
                      validatorText: "Please enter a question"),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: MultiLineTextField(
                        hintText: "Answer",
                        validatorText: "Please enter an answer",
                        controller: _answerField,
                        enabled: _editable),
                  ),
                  if (_editable)
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: TextFieldToolbar(controller: _answerField),
                    ),
                ],
              ),
            ),
          ),
        ));
  }
}
