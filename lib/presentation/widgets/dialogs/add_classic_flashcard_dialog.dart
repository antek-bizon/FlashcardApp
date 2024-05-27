import 'package:flashcards/data/models/classic_flashcard.dart';
import 'package:flashcards/data/models/quiz_group.dart';
import 'package:flashcards/data/models/quiz_item.dart';
import 'package:flashcards/presentation/widgets/colorful_textfield/colorful_text_editing_controller.dart';
import 'package:flashcards/presentation/widgets/colorful_textfield/text_field_toolbar.dart';
import 'package:flashcards/presentation/widgets/dialogs/add_quiz_item.dart';
import 'package:flashcards/presentation/widgets/multi_line_text_field.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';

class AddClassicFlashcardDialog extends StatefulWidget {
  final List<QuizItem> existingFlashcards;
  final QuizGroup group;

  const AddClassicFlashcardDialog({
    super.key,
    required this.existingFlashcards,
    required this.group,
  });

  @override
  State<AddClassicFlashcardDialog> createState() =>
      _AddClassicFlashcardDialogState();
}

class _AddClassicFlashcardDialogState extends State<AddClassicFlashcardDialog> {
  final _questionField = TextEditingController();
  final _answerField = ColorfulTextEditingController();
  XFileImage? _img;
  final FormFieldError _errorNotifier = FormFieldError();

  @override
  void dispose() {
    _errorNotifier.dispose();
    _questionField.dispose();
    _answerField.dispose();
    super.dispose();
  }

  void _onImage(List<dynamic>? imgs) {
    if (imgs != null && imgs.isNotEmpty) {
      _img = XFileImage(file: imgs.first);
    } else {
      _img = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AddQuizItemBodyDialog(
      title: "Add flashcard",
      currentDropdownValue: ClassicFlashcard.classValue,
      errorNotifier: _errorNotifier,
      onChanged: (type) =>
          onChange(context, type, widget.existingFlashcards, widget.group),
      onAdd: () {
        final item = QuizItem(
          type: QuizItemType.classic,
          data: ClassicFlashcard(
              question: _questionField.text, answer: _answerField.text),
        );

        if (widget.existingFlashcards.contains(item)) {
          _errorNotifier.setError("This flashcard already exists");
          return;
        }

        final data = item.data as ClassicFlashcard;
        data.styles = _answerField.styles;
        // widget.onAdd(item, _img);
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
        MultiLineTextField(
          controller: _answerField,
          labelText: "Answer",
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
    );
  }
}
