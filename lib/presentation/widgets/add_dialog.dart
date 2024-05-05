import 'dart:math';

import 'package:flashcards/data/models/flashcard.dart';
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
  final Function(String, String, XFileImage?) onAdd;
  final List<FlashcardModel> existingFlashcards;

  const AddFlashcardDialog(
      {super.key, required this.onAdd, required this.existingFlashcards});

  @override
  State<AddFlashcardDialog> createState() => _AddFlashcardDialogState();
}

class _AddFlashcardDialogState extends State<AddFlashcardDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _questionField = TextEditingController();
  final _answerField = TextEditingController();
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
                        TextFormField(
                          controller: _questionField,
                          decoration: const InputDecoration(
                              hintText: "Question",
                              contentPadding: EdgeInsets.only(left: 5)),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter some question";
                            }
                            return null;
                          },
                          onChanged: (_) {
                            if (isError) {
                              setState(() {
                                isError = false;
                              });
                            }
                          },
                        ),
                        TextFormField(
                          controller: _answerField,
                          decoration: const InputDecoration(
                              hintText: "Answer",
                              contentPadding: EdgeInsets.only(left: 5)),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter some answer";
                            }

                            return null;
                          },
                          onChanged: (_) {
                            if (isError) {
                              setState(() {
                                isError = false;
                              });
                            }
                          },
                        ),
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
                            final validationItem = FlashcardModel(
                                question: _questionField.text,
                                answer: _answerField.text);

                            if (widget.existingFlashcards
                                .contains(validationItem)) {
                              setState(() {
                                isError = true;
                              });
                            } else {
                              widget.onAdd(
                                  _questionField.text, _answerField.text, _img);
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
