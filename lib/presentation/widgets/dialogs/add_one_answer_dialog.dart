import 'package:flashcards/data/models/one_answer.dart';
import 'package:flashcards/data/models/quiz_group.dart';
import 'package:flashcards/data/models/quiz_item.dart';
import 'package:flashcards/presentation/widgets/dialogs/add_quiz_item.dart';
import 'package:flashcards/presentation/widgets/multi_line_text_field.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';

class AddOneAnswerDialog extends StatefulWidget {
  final List<QuizItem> existingFlashcards;
  final QuizGroup group;
  const AddOneAnswerDialog({
    super.key,
    required this.existingFlashcards,
    required this.group,
  });

  @override
  State<AddOneAnswerDialog> createState() => _AddOneAnswerDialogState();
}

class _AddOneAnswerDialogState extends State<AddOneAnswerDialog> {
  final FormFieldError _errorNotifier = FormFieldError();
  final _questionField = TextEditingController();
  final _scrollController = ScrollController();
  int? _selectedAnswerIndex;
  final List<TextEditingController> _controllers = [];
  XFileImage? _img;

  @override
  void dispose() {
    _errorNotifier.dispose();
    _questionField.dispose();
    _scrollController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onImage(List<dynamic>? imgs) {
    if (imgs != null && imgs.isNotEmpty) {
      _img = XFileImage(file: imgs.first);
    } else {
      _img = null;
    }
  }

  void _addAnswerField() {
    setState(() {
      _controllers.add(TextEditingController());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _removeAnswerField(int index) {
    setState(() {
      if (_selectedAnswerIndex != null && index == _selectedAnswerIndex) {
        _selectedAnswerIndex = null;
      } else if (_selectedAnswerIndex != null &&
          index < _selectedAnswerIndex!) {
        _selectedAnswerIndex = _selectedAnswerIndex! - 1;
      }
      _controllers.removeAt(index);
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(
        _scrollController.position.maxScrollExtent,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AddQuizItemBodyDialog(
      title: "Add item",
      currentDropdownValue: OneAnswer.classValues,
      errorNotifier: _errorNotifier,
      onChanged: (type) =>
          onChange(context, type, widget.existingFlashcards, widget.group),
      onAdd: () {
        if (_selectedAnswerIndex == null) {
          _errorNotifier.setError("Select correct answer");
          return;
        }
        final item = QuizItem(
          type: QuizItemType.oneAnswer,
          data: OneAnswer(
              question: _questionField.text.trim(),
              answers: _controllers.map((e) => e.text.trim()).toList(),
              correctAnswer: _selectedAnswerIndex!),
        );

        if (widget.existingFlashcards.contains(item)) {
          _errorNotifier.setError("This item already exists");
          return;
        }
        addQuizItem(context, group: widget.group, item: item, image: _img);
        Navigator.pop(context);
      },
      children: [
        MultiLineTextField(
          controller: _questionField,
          labelText: "Question",
          validatorText: "Please enter a question",
          onChanged: (_) {
            _errorNotifier.tryReset();
          },
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.3),
          child: ListView.builder(
            controller: _scrollController,
            shrinkWrap: true,
            itemCount: _controllers.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Radio<int>(
                      value: index,
                      groupValue: _selectedAnswerIndex,
                      onChanged: (int? value) {
                        setState(() {
                          _selectedAnswerIndex = value;
                        });
                      },
                    ),
                    Expanded(
                      child: MultiLineTextField(
                        controller: _controllers[index],
                        labelText: 'Answer ${String.fromCharCode(65 + index)}',
                        validatorText:
                            'Please enter answer ${String.fromCharCode(65 + index)}',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle),
                      onPressed: () => _removeAnswerField(index),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _addAnswerField(),
        ),
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
    );
  }
}
