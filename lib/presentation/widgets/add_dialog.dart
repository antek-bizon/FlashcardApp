import 'dart:math';

import 'package:flashcards/data/models/classic_flashcard.dart';
import 'package:flashcards/data/models/quiz_item.dart';
import 'package:flashcards/presentation/widgets/colorful_textfield/colorful_text_editing_controller.dart';
import 'package:flashcards/presentation/widgets/colorful_textfield/text_field_toolbar.dart';
import 'package:flashcards/presentation/widgets/multi_line_text_field.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';

class AddGroupDialog extends StatefulWidget {
  final Function(String) onAdd;
  final Set<String> existingGroups;

  const AddGroupDialog(
      {super.key, required this.onAdd, required this.existingGroups});

  @override
  State<AddGroupDialog> createState() => _AddGroupDialogState();
}

class _AddGroupDialogState extends State<AddGroupDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _groupNameField = TextEditingController();

  @override
  void dispose() {
    _groupNameField.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SizedBox(
          width: min(MediaQuery.of(context).size.width * 0.8, 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text("Add flashcard group"),
              const SizedBox(height: 15),
              Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _groupNameField,
                        decoration: const InputDecoration(
                            hintText: "Group name",
                            contentPadding: EdgeInsets.only(left: 5)),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter some group name";
                          } else if (widget.existingGroups.contains(value)) {
                            return "Group name already exists";
                          }
                          return null;
                        },
                      )
                    ],
                  )),
              // const SizedBox(height: 10),
              // IconButton(
              //     onPressed: () {},
              //     tooltip: "Add flashcard",
              //     icon: const Icon(Icons.add)),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.onAdd(_groupNameField.text);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Add"))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AddFlashcardDialog extends StatefulWidget {
  final void Function(QuizItem, XFileImage?) onAdd;
  final List<QuizItem> existingFlashcards;

  const AddFlashcardDialog(
      {super.key, required this.onAdd, required this.existingFlashcards});

  @override
  State<AddFlashcardDialog> createState() => _AddFlashcardDialogState();
}

class _AddFlashcardDialogState extends State<AddFlashcardDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _questionField = TextEditingController();
  final _answerField = ColorfulTextEditingController();
  XFileImage? _img;
  bool isError = false;

  @override
  void dispose() {
    _questionField.dispose();
    _answerField.dispose();
    super.dispose();
  }

  void _onImage(List<dynamic>? imgs) {
    setState(() {
      if (imgs != null && imgs.isNotEmpty) {
        _img = XFileImage(file: imgs.first);
      } else {
        _img = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SizedBox(
            width: min(MediaQuery.of(context).size.width * 0.8, 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Add flashcard"),
                const SizedBox(height: 15),
                Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        MultiLineTextField(
                          controller: _questionField,
                          hintText: "Question",
                          validatorText: "Please enter a question",
                          onChanged: (_) {
                            if (isError) {
                              setState(() {
                                isError = false;
                              });
                            }
                          },
                        ),
                        MultiLineTextField(
                          controller: _answerField,
                          hintText: "Answer",
                          validatorText: "Please enter an answer",
                          onChanged: (_) {
                            if (isError) {
                              setState(() {
                                isError = false;
                              });
                            }
                          },
                        ),
                        TextFieldToolbar(controller: _answerField),
                        FormBuilderImagePicker(
                          transformImageWidget: (context, displayImage) => Card(
                              // shape: const CircleBorder(),
                              clipBehavior: Clip.antiAlias,
                              child: Center(child: displayImage)),
                          name: 'photos',
                          maxImages: 1,
                          previewAutoSizeWidth: true,
                          availableImageSources: const [
                            ImageSourceOption.gallery
                          ],
                          onChanged: _onImage,
                        ),
                      ],
                    )),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final item = QuizItem(
                              type: QuizItemType.classic,
                              data: ClassicFlashcard(
                                  question: _questionField.text,
                                  answer: _answerField.text),
                            );

                            if (widget.existingFlashcards.contains(item)) {
                              setState(() {
                                isError = true;
                              });
                            } else {
                              final data = item.data as ClassicFlashcard;
                              data.styles = _answerField.styles;
                              widget.onAdd(item, _img);
                              Navigator.pop(context);
                            }
                          }
                        },
                        child: const Text("Add"))
                  ],
                ),
                Visibility(
                    visible: isError,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 35.0),
                      child: Text(
                        "There is already Flashcard with the same question and answer.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.error),
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
