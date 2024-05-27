import 'dart:math';

import 'package:flashcards/data/models/classic_flashcard.dart';
import 'package:flashcards/data/models/one_answer.dart';
import 'package:flashcards/data/models/quiz_item.dart';
import 'package:flashcards/presentation/widgets/colorful_textfield/colorful_text_editing_controller.dart';
import 'package:flashcards/presentation/widgets/colorful_textfield/text_field_toolbar.dart';
import 'package:flashcards/presentation/widgets/multi_line_text_field.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';

void _onChange(
    BuildContext context,
    QuizItemType type,
    List<QuizItem> existingFlashcards,
    void Function(QuizItem, XFileImage?) onAdd) {
  Navigator.pop(context);
  showDialog(
      context: context,
      builder: (context) {
        switch (type) {
          case QuizItemType.classic:
            return AddClassicFlashcardDialog(
                onAdd: onAdd, existingFlashcards: existingFlashcards);
          case QuizItemType.oneAnswer:
            return AddOneAnswerDialog(
                onAdd: onAdd, existingFlashcards: existingFlashcards);
          default:
            throw "Unknown quiz type";
        }
      });
}

class _FormFieldError with ChangeNotifier {
  bool _isError = false;
  bool get isError => _isError;

  void reset() {
    _isError = false;
    notifyListeners();
  }

  void tryReset() {
    if (_isError) {
      reset();
    }
  }

  void error() {
    _isError = true;
    notifyListeners();
  }
}

class _AddQuizItemDialog extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Widget _child;
  final VoidCallback _onAdd;
  final void Function(QuizItemType) _onChanged;
  final _FormFieldError _errorNotifier;
  final String _errorMessage;
  final QuizItemId _currentDropdownValue;
  static const _quizTypes = [
    ClassicFlashcard.classValue,
    OneAnswer.classValues,
  ];
  _AddQuizItemDialog(
      {required Widget child,
      required void Function() onAdd,
      required void Function(QuizItemType) onChanged,
      required _FormFieldError errorNotifier,
      required String errorMessage,
      required QuizItemId currentDropdownValue})
      : _currentDropdownValue = currentDropdownValue,
        _errorMessage = errorMessage,
        _errorNotifier = errorNotifier,
        _onAdd = onAdd,
        _onChanged = onChanged,
        _child = child;

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
                DropdownButton(
                  value: _currentDropdownValue,
                  items: _quizTypes.map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Text(e.name),
                    );
                  }).toList(),
                  onChanged: (QuizItemId? value) {
                    if (value != null && value != _currentDropdownValue) {
                      _onChanged(value.type);
                    }
                  },
                ),
                const SizedBox(height: 15),
                Form(
                  key: _formKey,
                  child: _child,
                ),
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
                            _onAdd();
                          }
                        },
                        child: const Text("Add"))
                  ],
                ),
                ListenableBuilder(
                  listenable: _errorNotifier,
                  builder: (context, child) => Visibility(
                      visible: _errorNotifier.isError,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 35.0),
                        child: Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.error),
                        ),
                      )),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddClassicFlashcardDialog extends StatefulWidget {
  final void Function(QuizItem, XFileImage?) onAdd;
  final List<QuizItem> existingFlashcards;

  const AddClassicFlashcardDialog(
      {super.key, required this.onAdd, required this.existingFlashcards});

  @override
  State<AddClassicFlashcardDialog> createState() =>
      _AddClassicFlashcardDialogState();
}

class _AddClassicFlashcardDialogState extends State<AddClassicFlashcardDialog> {
  final _questionField = TextEditingController();
  final _answerField = ColorfulTextEditingController();
  XFileImage? _img;
  final _FormFieldError _errorNotifier = _FormFieldError();

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
    return _AddQuizItemDialog(
      currentDropdownValue: ClassicFlashcard.classValue,
      errorNotifier: _errorNotifier,
      errorMessage: "This flashcard already exists",
      onChanged: (type) =>
          _onChange(context, type, widget.existingFlashcards, widget.onAdd),
      onAdd: () {
        final item = QuizItem(
          type: QuizItemType.classic,
          data: ClassicFlashcard(
              question: _questionField.text, answer: _answerField.text),
        );

        if (widget.existingFlashcards.contains(item)) {
          _errorNotifier.error();
        } else {
          final data = item.data as ClassicFlashcard;
          data.styles = _answerField.styles;
          widget.onAdd(item, _img);
          Navigator.pop(context);
        }
      },
      child: Column(
        children: [
          MultiLineTextField(
            controller: _questionField,
            hintText: "Question",
            validatorText: "Please enter a question",
            onChanged: (_) {
              _errorNotifier.tryReset();
            },
          ),
          MultiLineTextField(
            controller: _answerField,
            hintText: "Answer",
            validatorText: "Please enter an answer",
            onChanged: (_) {
              _errorNotifier.tryReset();
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
            availableImageSources: const [ImageSourceOption.gallery],
            onChanged: _onImage,
          ),
        ],
      ),
    );
  }
}

class AddOneAnswerDialog extends StatefulWidget {
  final void Function(QuizItem, XFileImage?) onAdd;
  final List<QuizItem> existingFlashcards;
  const AddOneAnswerDialog(
      {super.key, required this.onAdd, required this.existingFlashcards});

  @override
  State<AddOneAnswerDialog> createState() => _AddOneAnswerDialogState();
}

class _AddOneAnswerDialogState extends State<AddOneAnswerDialog> {
  final _FormFieldError _errorNotifier = _FormFieldError();

  @override
  Widget build(BuildContext context) {
    return _AddQuizItemDialog(
      currentDropdownValue: OneAnswer.classValues,
      errorMessage: "This item already exists",
      errorNotifier: _errorNotifier,
      onChanged: (type) =>
          _onChange(context, type, widget.existingFlashcards, widget.onAdd),
      onAdd: () {},
      child: const Column(),
    );
  }
}
