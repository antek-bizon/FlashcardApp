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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _previousPage() {
    _controller.previousPage(
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  void _nextPage() {
    _controller.nextPage(
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
          // backgroundColor: Theme.of(context).colorScheme.primary,
          ),
      body: DefaultBody(
        child: PageView(
          controller: _controller,
          children: widget.flashcards
              .map((e) => Padding(
                    padding: const EdgeInsets.all(50.0),
                    child:
                        FlashcardWidget(question: e.question, answer: e.answer),
                  ))
              .toList(growable: false),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              onPressed: _previousPage,
              icon: const Icon(Icons.arrow_back_ios_rounded)),
          addSpacing(width: min(MediaQuery.of(context).size.width * 0.2, 100)),
          IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              onPressed: _nextPage,
              icon: const Icon(Icons.arrow_forward_ios_rounded))
        ]),
      ),
    );
  }
}
