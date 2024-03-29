import 'package:flashcards/data/models/flashcard.dart';
import 'package:flashcards/presentation/widgets/dropdown_image.dart';
import 'package:flashcards/utils.dart';
import 'package:flutter/material.dart';

class FlashcardListItem extends StatefulWidget {
  const FlashcardListItem(
      {super.key,
      required this.index,
      required this.flashcard,
      required this.flashcardKey,
      required this.onDelete,
      required this.onUpdate});

  final FlashcardModel flashcard;
  final String flashcardKey;
  final int index;
  final VoidCallback onDelete;
  final Function() onUpdate;

  @override
  State<FlashcardListItem> createState() => _FlashcardListItemState();
}

class _FlashcardListItemState extends State<FlashcardListItem> {
  bool editable = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _questionField;
  late TextEditingController _answerField;

  @override
  void initState() {
    _questionField = TextEditingController(text: widget.flashcard.question);
    _answerField = TextEditingController(text: widget.flashcard.answer);
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
    });

    await widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final image = getImage(widget.flashcard.imageUri);

    return Card(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
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
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _questionField,
                            enabled: editable,
                            decoration: const InputDecoration(
                                hintText: "Question",
                                contentPadding: EdgeInsets.only(left: 5)),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter some question";
                              }
                              return null;
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: TextFormField(
                              controller: _answerField,
                              enabled: editable,
                              decoration: const InputDecoration(
                                  hintText: "Answer",
                                  contentPadding: EdgeInsets.only(left: 5)),
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter some answer";
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
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
