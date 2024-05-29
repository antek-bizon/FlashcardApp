import 'dart:math';

import 'package:flashcards/cubits/quiz_items.dart';
import 'package:flashcards/data/models/classic_flashcard.dart';
import 'package:flashcards/data/models/one_answer.dart';
import 'package:flashcards/data/models/quiz_group.dart';
import 'package:flashcards/data/models/quiz_item.dart';
import 'package:flashcards/presentation/widgets/dialogs/add_classic_flashcard_dialog.dart';
import 'package:flashcards/presentation/widgets/dialogs/add_one_answer_dialog.dart';
import 'package:flashcards/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';

void onChange(BuildContext context, QuizItemType type,
    List<QuizItem> existingFlashcards, QuizGroup group) {
  Navigator.pop(context);
  showDialog(
      context: context,
      builder: (context) {
        switch (type) {
          case QuizItemType.classic:
            return AddClassicFlashcardDialog(
                group: group, existingFlashcards: existingFlashcards);
          case QuizItemType.oneAnswer:
            return AddOneAnswerDialog(
                group: group, existingFlashcards: existingFlashcards);
          default:
            throw "Unknown quiz type";
        }
      });
}

void addQuizItem(BuildContext context,
    {required QuizGroup group, required QuizItem item, XFileImage? image}) {
  context.read<QuizItemCubit>().addQuizItem(
      authState: authState(context), group: group, item: item, image: image);
}

class FormFieldError with ChangeNotifier {
  String? _error;
  bool get isError => _error != null;
  String get error => _error ?? "";

  void reset() {
    _error = null;
    notifyListeners();
  }

  void tryReset() {
    if (isError) {
      reset();
    }
  }

  void setError(String message) {
    _error = message;
    notifyListeners();
  }
}

class AddQuizItemBodyDialog extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<Widget> _children;
  final VoidCallback _onAdd;
  final void Function(QuizItemType) _onChanged;
  final FormFieldError _errorNotifier;
  final String _title;
  final QuizItemId _currentDropdownValue;
  static const _quizTypes = [
    ClassicFlashcard.classValue,
    OneAnswer.classValues,
  ];
  AddQuizItemBodyDialog(
      {super.key,
      required List<Widget> children,
      required void Function() onAdd,
      required void Function(QuizItemType) onChanged,
      required FormFieldError errorNotifier,
      required String title,
      required QuizItemId currentDropdownValue})
      : _currentDropdownValue = currentDropdownValue,
        _errorNotifier = errorNotifier,
        _title = title,
        _onAdd = onAdd,
        _onChanged = onChanged,
        _children = children;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
          child: SizedBox(
            width: min(MediaQuery.of(context).size.width * 0.8, 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_title),
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
                Form(
                  key: _formKey,
                  child: Column(
                    children: _children,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
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
                ),
                ListenableBuilder(
                  listenable: _errorNotifier,
                  builder: (context, child) => Visibility(
                      visible: _errorNotifier.isError,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 35.0),
                        child: Text(
                          _errorNotifier.error,
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
