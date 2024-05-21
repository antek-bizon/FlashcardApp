import 'dart:math';

import 'package:flashcards/data/models/flashcard.dart';
import 'package:flashcards/presentation/widgets/flashcard_widget.dart';
import 'package:flashcards/utils.dart';
import 'package:flashcards/presentation/widgets/default_body.dart';
import 'package:flutter/material.dart';

class PresentationPage extends StatefulWidget {
  const PresentationPage({super.key, required this.flashcards});

  final List<FlashcardModel> flashcards;

  @override
  State<PresentationPage> createState() => _PresentationPageState();
}

class _PresentationPageState extends State<PresentationPage> {
  final PageController _controller = PageController(initialPage: 0);
  final List<FlashcardModel> _incorrectAnswers = [];
  bool _animation = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_controller.page!.toInt() < widget.flashcards.length - 1) {
      _animation = true;
      _controller
          .nextPage(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut)
          .then((_) => _animation = false);
    } else if (_incorrectAnswers.isNotEmpty) {
      showDialog(
          context: context,
          builder: _continueDialog,
          barrierDismissible: false);
    } else {
      showDialog(
        context: context,
        builder: _endDialog,
        barrierDismissible: false,
      );
    }
  }

  Widget _continueDialog(BuildContext context) {
    return AlertDialog(
      title: Text('${_incorrectAnswers.length} incorrect answers'),
      content: const Text('Do you want to continue studying them?'),
      actions: <Widget>[
        TextButton(
          child: const Text('Continue'),
          onPressed: () {
            final list = _incorrectAnswers;
            list.shuffle();
            Navigator.pop(context);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => PresentationPage(flashcards: list)));
          },
        ),
        TextButton(
          child: const Text('Leave'),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _endDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Congratulations!'),
      content: const Text('You answered everything correctly!'),
      actions: <Widget>[
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  void _correct() {
    if (!_animation) {
      _nextPage();
    }
  }

  void _incorrect() {
    if (!_animation) {
      _incorrectAnswers.add(widget.flashcards[_controller.page!.toInt()]);
      _nextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: DefaultBody(
        child: PageView(
          controller: _controller,
          children: widget.flashcards
              .map((e) => Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: FlashcardWidget(
                      item: e,
                    ),
                  ))
              .toList(growable: false),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              onPressed: _incorrect,
              icon: const Icon(Icons.close_rounded)),
          addSpacing(width: min(MediaQuery.of(context).size.width * 0.2, 100)),
          IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              onPressed: _correct,
              icon: const Icon(Icons.check_rounded))
        ]),
      ),
    );
  }
}
