import 'dart:math';

import 'package:flashcards/data/models/classic_flashcard.dart';
import 'package:flashcards/data/models/one_answer.dart';
import 'package:flashcards/data/models/quiz_item.dart';
import 'package:flashcards/presentation/widgets/presentation_widget/flashcard_widget.dart';
import 'package:flashcards/presentation/widgets/presentation_widget/one_answer_widget.dart';
import 'package:flashcards/utils.dart';
import 'package:flashcards/presentation/widgets/default_body.dart';
import 'package:flutter/material.dart';

class PresentationPage extends StatefulWidget {
  const PresentationPage({super.key, required this.items});

  final List<QuizItem> items;

  @override
  State<PresentationPage> createState() => _PresentationPageState();
}

class _PresentationPageState extends State<PresentationPage> {
  final PageController _controller = PageController(initialPage: 0);
  final List<QuizItem> _incorrectAnswers = [];
  bool _animation = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_controller.page!.toInt() < widget.items.length - 1) {
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
                    builder: (context) => PresentationPage(items: list)));
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
      _incorrectAnswers.add(widget.items[_controller.page!.toInt()]);
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
          children: widget.items.map<Widget>((e) {
            switch (e.type) {
              case QuizItemType.classic:
                return FlashcardWidget(
                  item: e.data as ClassicFlashcard,
                  imageUri: e.imageUri,
                );
              case QuizItemType.oneAnswer:
                return OneAnswerWidget(
                  item: e.data as OneAnswer,
                  imageUri: e.imageUri,
                );
              // default:
              //   return null;
            }
          }).toList(growable: false),
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
