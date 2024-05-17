import 'package:flashcards/data/models/flashcard.dart';
import 'package:flashcards/presentation/widgets/colorful_textfield/colorful_text_editing_controller.dart';
import 'package:flashcards/utils.dart';
import 'package:flutter/material.dart';

class FlashcardWidget extends StatefulWidget {
  final FlashcardModel item;

  const FlashcardWidget({
    super.key,
    required this.item,
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
      child: FlashcardDraft(
        item: widget.item,
        showFront: _showFront,
      ),
    );
  }
}

class FlashcardDraft extends StatelessWidget {
  const FlashcardDraft(
      {super.key,
      required this.item,
      // required this.question,
      // required this.answer,
      // this.imageUri,
      // this.textStyle,
      required this.showFront,
      this.backColor = Colors.teal});
  // final String question;
  // final String answer;
  // final String? imageUri;
  // final String? textStyle;
  final FlashcardModel item;
  final bool showFront;
  final Color backColor;

  Color _sideColor(BuildContext context) {
    return Color.lerp((showFront) ? Colors.blueAccent : backColor,
                Theme.of(context).colorScheme.secondaryContainer, 0.65)
            ?.withAlpha(170) ??
        Colors.orangeAccent.withAlpha(150);
  }

  String _sideTitle() {
    return (showFront) ? "Question" : "Answer";
  }

  @override
  Widget build(BuildContext context) {
    final image = getImage(item.imageUri);
    final list = item.styles ?? StylesList.generate(item.answer.length);
    final theme = Theme.of(context);

    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        color: _sideColor(context),
        alignment: Alignment.center,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 20),
            child: Text(
              _sideTitle(),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const Divider(
            color: Colors.black54,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: showFront
                    ? Text(
                        item.question,
                        style: const TextStyle(
                          fontSize: 20.0,
                        ),
                      )
                    : RichText(
                        text: list.toTextSpan(context, item.answer,
                            style: TextStyle(
                                fontSize: 20.0,
                                fontFamily:
                                    theme.textTheme.bodyMedium?.fontFamily,
                                color: theme.colorScheme.onSurface))),
              ),
            ),
          ),
          if (image != null)
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: image,
              ),
            )
        ]),
      ),
    );
  }
}
