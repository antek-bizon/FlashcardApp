import 'dart:math';

import 'package:flashcards/data/models/flashcard.dart';
import 'package:flashcards/presentation/widgets/flashcard_widget.dart';
import 'package:flashcards/utils.dart';
import 'package:flashcards/presentation/widgets/default_body.dart';
import 'package:flutter/material.dart';

enum ExamItemState { none, correct, wrong }

class ExamItem extends FlashcardModel {
  ExamItemState state = ExamItemState.none;
  ExamItem({required FlashcardModel flashcard})
      : super(
            question: flashcard.question,
            answer: flashcard.answer,
            imageUri: flashcard.imageUri);
}

class WrongAnswer extends FlashcardModel {
  final String userAnswer;
  WrongAnswer({required FlashcardModel flashcard, required this.userAnswer})
      : super(question: flashcard.question, answer: flashcard.answer);
}

// ignore: must_be_immutable
class ExamPage extends StatefulWidget {
  final List<ExamItem> examItems;

  ExamPage({super.key, required List<FlashcardModel> flashcards})
      : examItems = flashcards
            .map((e) => ExamItem(flashcard: e))
            .toList(growable: false)
          ..shuffle();

  @override
  State<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  final _controller = PageController();
  late List<GlobalKey<FormState>> _formKeys;
  late List<TextEditingController> _textFields;
  final List<WrongAnswer> _wrongAnswers = [];
  var answered = false;
  var score = 0;

  @override
  void initState() {
    _formKeys = List.generate(
        widget.examItems.length, (_) => GlobalKey<FormState>(),
        growable: false);
    _textFields = List.generate(
        widget.examItems.length, (_) => TextEditingController(),
        growable: false);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    for (var e in _textFields) {
      e.dispose();
    }
    super.dispose();
  }

  void _checkAnswer() {
    final currentPage = _controller.page!.toInt();
    if (_formKeys[currentPage].currentState!.validate()) {
      final examItem = widget.examItems[currentPage];
      final isAnswerCorrect = _textFields[currentPage].text.toLowerCase() ==
          examItem.answer.toLowerCase();
      setState(() {
        examItem.state =
            (isAnswerCorrect) ? ExamItemState.correct : ExamItemState.wrong;
        if (isAnswerCorrect) {
          score += 1;
        } else {
          _wrongAnswers.add(WrongAnswer(
              flashcard: examItem, userAnswer: _textFields[currentPage].text));
        }
        answered = true;
      });
    }
  }

  Widget _wrongAnswersList() {
    return Column(children: [
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: SizedBox(
          width: 300,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Correct answer"),
              Text("Your answer"),
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 300,
          height: min(_wrongAnswers.length * 30, 150),
          child: ListView.builder(
            itemCount: _wrongAnswers.length,
            itemBuilder: (context, index) {
              final data = _wrongAnswers[index];
              return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [Text(data.answer), Text(data.userAnswer)]);
            },
          ),
        ),
      ),
    ]);
  }

  void _tryNextPage() {
    if (_controller.page!.toInt() < widget.examItems.length - 1) {
      setState(() {
        answered = false;
      });
      _controller.nextPage(
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    } else {
      showDialog(
          context: context,
          builder: (context) => Dialog(
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Test finished",
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Your score: $score",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      if (_wrongAnswers.isNotEmpty) _wrongAnswersList(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: const Text("Return")),
                      )
                    ],
                  ),
                ),
              ));
    }
  }

  IconButton _bottomButton() {
    return (!answered)
        ? IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            // color: Theme.of(context).colorScheme.onPrimary,
            onPressed: _checkAnswer,
            icon: const Icon(Icons.check))
        : IconButton(
            onPressed: () {
              _tryNextPage();
            },
            icon: const Icon(Icons.arrow_forward_ios_rounded));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          "Score: $score",
          // style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        centerTitle: true,
        // iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        // backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: DefaultBody(
        child: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _controller,
          children: List.generate(widget.examItems.length, (index) {
            final e = widget.examItems[index];

            return (Padding(
              padding: const EdgeInsets.only(
                  left: 50.0, right: 50.0, top: 25.0, bottom: 50.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Form(
                      key: _formKeys[index],
                      child: TextFormField(
                        controller: _textFields[index],
                        enabled: !answered,
                        decoration: const InputDecoration(
                            hintText: "Answer",
                            contentPadding: EdgeInsets.only(left: 5)),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter some answer";
                          }
                          return null;
                        },
                      )),
                  addSpacing(height: 25),
                  Expanded(
                    child: FlashcardDraft(
                      question: e.question,
                      answer: e.answer,
                      imageUri: e.imageUri,
                      textStyle: e.textStyle,
                      showFront: e.state == ExamItemState.none,
                      backColor: e.state == ExamItemState.wrong
                          ? const Color.fromARGB(255, 255, 4, 0)
                          : Colors.lightGreen,
                    ),
                  ),
                ],
              ),
            ));
          }),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        // color: Colors.black38,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_bottomButton()]),
      ),
    );
  }
}
