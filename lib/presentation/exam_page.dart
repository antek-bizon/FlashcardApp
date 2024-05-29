import 'dart:math';

import 'package:flashcards/data/models/classic_flashcard.dart';
import 'package:flashcards/data/models/classic_flashcard_exam_item.dart';
import 'package:flashcards/data/models/exam_data.dart';
import 'package:flashcards/data/models/one_answer.dart';
import 'package:flashcards/data/models/one_answer_exam_item.dart';
import 'package:flashcards/data/models/quiz_item.dart';
import 'package:flashcards/presentation/widgets/default_body.dart';
import 'package:flutter/material.dart';

class ExamPage extends StatefulWidget {
  final List<QuizItem> items;
  static const correctAnswerColor = Colors.lightGreen;
  static const wrongAnswerColor = Colors.red;

  const ExamPage({super.key, required this.items});

  @override
  State<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  late List<ExamItem> _items;
  final _controller = PageController();
  final List<WrongAnswer> _wrongAnswers = [];
  var answered = false;
  var score = 0;

  @override
  void initState() {
    _items = widget.items.map<ExamItem>((e) {
      switch (e.type) {
        case QuizItemType.classic:
          return ClassicFlashcardExamItem(
              data: e.data as ClassicFlashcard, imageUri: e.imageUri);
        case QuizItemType.oneAnswer:
          return OneAnswerExamItem(
              data: e.data as OneAnswer, imageUri: e.imageUri);
      }
    }).toList();
    super.initState();
  }

  @override
  void dispose() {
    for (final item in _items) {
      item.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    final currentPage = _controller.page!.toInt();
    final examItem = _items[currentPage];
    final validAnswer = examItem.isAnswerCorrect();
    if (validAnswer != null) {
      final (isAnswerCorrect, correctAnswer, userAnswer) = validAnswer;
      setState(() {
        examItem.state = (isAnswerCorrect == true)
            ? ExamItemState.correct
            : ExamItemState.wrong;
        if (isAnswerCorrect == true) {
          score += 1;
        } else {
          _wrongAnswers.add(WrongAnswer(
            correctAnswer: correctAnswer,
            userAnswer: userAnswer,
          ));
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
          child: ListView.separated(
            itemCount: _wrongAnswers.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final data = _wrongAnswers[index];
              return Row(children: [
                _AnswerListItem(data.correctAnswer),
                _AnswerListItem(data.userAnswer)
              ]);
            },
          ),
        ),
      ),
    ]);
  }

  void _tryNextPage() {
    if (_controller.page!.toInt() < _items.length - 1) {
      setState(() {
        answered = false;
      });
      _controller.nextPage(
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    } else {
      showDialog(context: context, builder: _dialog, barrierDismissible: false);
    }
  }

  Widget _dialog(context) {
    return AlertDialog(
      title: const Center(child: Text("Test finished")),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Your score: $score",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (_wrongAnswers.isNotEmpty) _wrongAnswersList(),
        ],
      ),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Return"),
          ),
        )
      ],
    );
  }

  IconButton _bottomButton() {
    return (!answered)
        ? IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            onPressed: _checkAnswer,
            icon: const Icon(Icons.check))
        : IconButton(
            onPressed: _tryNextPage,
            icon: const Icon(Icons.arrow_forward_rounded));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          "Score: $score",
        ),
        centerTitle: true,
      ),
      body: DefaultBody(
        child: PageView.builder(
          itemBuilder: (context, index) => ExamListItem(item: _items[index]),
          itemCount: _items.length,
          controller: _controller,
          physics: const NeverScrollableScrollPhysics(),
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

class ExamListItem extends StatelessWidget {
  const ExamListItem({
    super.key,
    required ExamItem item,
  }) : _item = item;

  final ExamItem _item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 50.0, right: 50.0, top: 25.0, bottom: 50.0),
      child: _item.widget,
    );
  }
}

class _AnswerListItem extends StatelessWidget {
  const _AnswerListItem(
    this.text,
  );

  final String text;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        softWrap: true,
      ),
    );
  }
}
