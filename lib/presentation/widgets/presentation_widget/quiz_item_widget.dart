import 'package:flashcards/utils.dart';
import 'package:flutter/material.dart';

class QuizItemWidget extends StatelessWidget {
  const QuizItemWidget({
    super.key,
    required String? imageUri,
    required bool showFront,
    required String title,
    required Widget child,
    Color? backColor,
  })  : _showFront = showFront,
        _imageUri = imageUri,
        _backColor = backColor ?? Colors.teal,
        _title = title,
        _child = child;

  final Widget _child;
  final String _title;
  final Color _backColor;
  final String? _imageUri;
  final bool _showFront;

  Color _sideColor(BuildContext context) {
    return Color.lerp((_showFront) ? Colors.blueAccent : _backColor,
                Theme.of(context).colorScheme.secondaryContainer, 0.65)
            ?.withAlpha(170) ??
        Colors.orangeAccent.withAlpha(150);
  }

  @override
  Widget build(BuildContext context) {
    final image = getImage(_imageUri);

    return Padding(
      padding: const EdgeInsets.all(50),
      child: Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          color: _sideColor(context),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 30, bottom: 20, left: 25, right: 25),
              child: Text(
                _title,
                softWrap: true,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const Divider(
              color: Colors.black54,
            ),
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: _child),
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
      ),
    );
  }
}
