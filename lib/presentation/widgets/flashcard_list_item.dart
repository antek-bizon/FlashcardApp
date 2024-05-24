import 'package:flashcards/data/models/classic_flashcard.dart';
import 'package:flashcards/presentation/widgets/colorful_textfield/colorful_text_editing_controller.dart';
import 'package:flashcards/presentation/widgets/colorful_textfield/text_field_toolbar.dart';
import 'package:flashcards/presentation/widgets/dropdown_image.dart';
import 'package:flashcards/presentation/widgets/multi_line_text_field.dart';
import 'package:flashcards/utils.dart';
import 'package:flutter/material.dart';

class FlashcardListItem extends StatefulWidget {
  const FlashcardListItem(
      {super.key,
      required this.index,
      required this.flashcard,
      required this.flashcardKey,
      required this.imageUri,
      required this.onDelete,
      required this.onUpdate});

  final ClassicFlashcard flashcard;
  final String flashcardKey;
  final String? imageUri;
  final int index;
  final VoidCallback onDelete;
  final void Function() onUpdate;

  @override
  State<FlashcardListItem> createState() => _FlashcardListItemState();
}

class _FlashcardListItemState extends State<FlashcardListItem> {
  bool editable = false;
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

  Icon _editableIcon() {
    return (editable) ? const Icon(Icons.save) : const Icon(Icons.edit);
  }

  Future<void> _updateFlashcard() async {
    setState(() {
      widget.flashcard.question = _questionField.text;
      widget.flashcard.answer = _answerField.text;
      widget.flashcard.styles = _answerField.styles;
    });

    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final image = getImage(widget.imageUri);
    _answerField.setDefaultColor(Theme.of(context).colorScheme.onSurface);

    return Card(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child:
                      CircleAvatar(child: Text((widget.index + 1).toString())),
                ),
                const VerticalDivider(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 1.0),
                    child: Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: Column(
                          children: [
                            MultiLineTextField(
                                controller: _questionField,
                                enabled: editable,
                                hintText: "Question",
                                validatorText: "Please enter a question"),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 2.0),
                              child: MultiLineTextField(
                                  hintText: "Answer",
                                  validatorText: "Please enter an answer",
                                  controller: _answerField,
                                  enabled: editable),
                            ),
                            if (editable)
                              Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child:
                                    TextFieldToolbar(controller: _answerField),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      IconButton(
                        icon: _editableIcon(),
                        onPressed: () {
                          setState(() {
                            if (!editable) {
                              editable = !editable;
                            } else if (editable &&
                                _formKey.currentState!.validate()) {
                              _updateFlashcard();
                              editable = !editable;
                            }
                          });
                        },
                      ),
                      addSpacing(height: 10),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          widget.onDelete();
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
            if (image != null)
              DropdownImage(
                image: image,
              )
          ],
        ));
  }
}
