import 'package:flashcards/data/models/classic_flashcard.dart';
import 'package:flashcards/presentation/widgets/colorful_textfield/colorful_text_editing_controller.dart';
import 'package:flashcards/presentation/widgets/presentation_widget/quiz_item_widget.dart';
import 'package:flutter/material.dart';

class FlashcardWidget extends StatefulWidget {
  final ClassicFlashcard item;
  final String? imageUri;

  const FlashcardWidget({
    super.key,
    required this.item,
    required this.imageUri,
  });

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget> {
  bool _showFront = true;

  void _toggleCard() {
    setState(() {
      _showFront = !_showFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleCard,
      child: ExamFlashcardWidget(
        item: widget.item,
        showFront: _showFront,
        imageUri: widget.imageUri,
      ),
    );
  }
}

class ExamFlashcardWidget extends StatelessWidget {
  const ExamFlashcardWidget(
      {super.key,
      required ClassicFlashcard item,
      required String? imageUri,
      required bool showFront,
      Color? backColor})
      : _imageUri = imageUri,
        _item = item,
        _showFront = showFront,
        _backColor = backColor;
  final ClassicFlashcard _item;
  final Color? _backColor;
  final String? _imageUri;
  final bool _showFront;

  String _title() {
    return (_showFront) ? "Question" : "Answer";
  }

  @override
  Widget build(BuildContext context) {
    final list = _item.styles ?? StylesList.generate(_item.answer.length);
    final theme = Theme.of(context);

    return QuizItemWidget(
      imageUri: _imageUri,
      showFront: _showFront,
      backColor: _backColor,
      title: _title(),
      child: Center(
        child: _showFront
            ? Text(
                _item.question,
                style: const TextStyle(
                  fontSize: 20.0,
                ),
              )
            : RichText(
                text: list.toTextSpan(context, _item.answer,
                    style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: theme.textTheme.bodyMedium?.fontFamily,
                        color: theme.colorScheme.onSurface))),
      ),
    );
  }
}
