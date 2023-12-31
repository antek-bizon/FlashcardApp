import 'package:flashcards/model/db.dart';
import 'package:flashcards/pages/exam_page.dart';
import 'package:flashcards/widgets/add_dialog.dart';
import 'package:flashcards/flashcards/flashcard.dart';
import 'package:flashcards/pages/presentation_page.dart';
import 'package:flashcards/utils.dart';
import 'package:flashcards/widgets/default_body.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum MenuItem {
  //  reorder,
  deleteGroup
}

class FlashcardGroupPage extends StatefulWidget {
  final String groupName;
  // final List<Flashcard> flashcardGroup;
  final VoidCallback onDelete;
  const FlashcardGroupPage({
    super.key,
    required this.groupName,
    // required this.flashcardGroup,
    required this.onDelete,
  });

  @override
  State<FlashcardGroupPage> createState() => _FlashcardGroupPageState();
}

class _FlashcardGroupPageState extends State<FlashcardGroupPage> {
  bool _isLoading = true;
  set loading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchFlashcards();
  }

  void _onMenuSelected(MenuItem option, BuildContext context) {
    switch (option) {
      // case MenuItem.reorder:
      //   setState(() {
      //     _reorderList = !_reorderList;
      //   });
      //   break;
      case MenuItem.deleteGroup:
        widget.onDelete();
        break;
      default:
        break;
    }
  }

  Future<void> _fetchFlashcards() async {
    loading = true;
    await Provider.of<DatabaseModel>(listen: false, context)
        .getFlashcards(widget.groupName);
    loading = false;
  }

  Future<void> _addToGroup(String question, String answer) async {
    loading = true;
    await Provider.of<DatabaseModel>(listen: false, context).addFlashcard(
        widget.groupName, Flashcard(question: question, answer: answer));
    loading = false;
  }

  Future<void> _removeFromGroup(int index) async {
    loading = true;
    await Provider.of<DatabaseModel>(context, listen: false)
        .removeFlashcard(widget.groupName, index);
    loading = false;
  }

  Future<void> _updateFlashcard(int index) async {
    loading = true;
    Provider.of<DatabaseModel>(context, listen: false)
        .updateFlashcard(widget.groupName, index);
    loading = false;
  }

  void _showAddDialog(BuildContext context) {
    // _endReoreder();
    showDialog<String>(
        context: context,
        builder: (BuildContext context) =>
            AddFlashcardDialog(onAdd: _addToGroup));
  }

  void _showPresentationPage(
      BuildContext context, List<Flashcard> flashcardGroup) {
    // _endReoreder();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PresentationPage(flashcards: flashcardGroup)),
    );
  }

  void _showExamPage(BuildContext context, List<Flashcard> flashcardGroup) {
    // _endReoreder();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ExamPage(flashcards: flashcardGroup)),
    );
  }

  // void _endReoreder() {
  //   setState(() {
  //     _reorderList = false;
  //   });
  // }

  // void _onReorder(int oldIndex, int newIndex) async {
  //   final flashcardGroup = await _flashcardGroup;
  //   setState(() {
  //     if (oldIndex < newIndex) {
  //       newIndex -= 1;
  //     }
  //     final item = flashcardGroup.removeAt(oldIndex);
  //     flashcardGroup.insert(newIndex, item);
  //   });
  //   await _updateJson(flashcardGroup);
  // }
  // ReorderableListView _reorderableListView(List<Flashcard> flashcardGroup) {
  //   final List<ReorderableFlashcardItem> listItems = [
  //     for (int i = 0; i < flashcardGroup.length; i += 1)
  //       ReorderableFlashcardItem(
  //         key: UniqueKey(),
  //         index: i,
  //         flashcard: flashcardGroup[i],
  //       )
  //   ];
  //   Widget proxyDecorator(
  //       Widget child, int index, Animation<double> animation) {
  //     return AnimatedBuilder(
  //       animation: animation,
  //       builder: (BuildContext context, Widget? child) {
  //         final double animValue = Curves.easeInOut.transform(animation.value);
  //         final double elevation = lerpDouble(1, 6, animValue)!;
  //         final double scale = lerpDouble(1, 1.02, animValue)!;
  //         return Transform.scale(
  //             scale: scale,
  //             // Create a Card based on the color and the content of the dragged one
  //             // and set its elevation to the animated value.
  //             child: ReorderableFlashcardItem(
  //               key: UniqueKey(),
  //               index: listItems[index].index,
  //               flashcard: listItems[index].flashcard,
  //               elevation: elevation,
  //             ));
  //       },
  //       child: child,
  //     );
  //   }
  //   return ReorderableListView(
  //     onReorder: _onReorder,
  //     proxyDecorator: proxyDecorator,
  //     padding: const EdgeInsets.symmetric(horizontal: 15.0),
  //     physics: const BouncingScrollPhysics(),
  //     children: listItems,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    // if (!context.mounted) return const Scaffold();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.groupName,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Provider.of<DatabaseModel>(context, listen: false)
                .clearFlashcards();
            Navigator.maybePop(context);
          },
        ),
        actions: [
          PopupMenuButton<MenuItem>(
            onSelected: (MenuItem option) {
              _onMenuSelected(option, context);
            },
            itemBuilder: (context) => <PopupMenuEntry<MenuItem>>[
              // PopupMenuItem<MenuItem>(
              //   value: MenuItem.reorder,
              //   enabled: !isFlashcardsEmpty,
              //   child: (!_reorderList)
              //       ? const Text("Reorder elements")
              //       : const Text("End reordering"),
              // ),
              const PopupMenuItem<MenuItem>(
                value: MenuItem.deleteGroup,
                child: Text("Delete whole group"),
              ),
            ],
          )
        ],
      ),
      body: DefaultBody(
        child: Consumer<DatabaseModel>(
          builder: (context, db, _) {
            if (_isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final flashcards = db.flashcards;

            // if (_reorderList) {
            //   return _reorderableListView(flashcardGroup);
            // }

            return SafeArea(
              child: ListView.builder(
                  itemCount: flashcards.length,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width *
                          MediaQuery.of(context).size.width /
                          10000),
                  itemBuilder: (context, index) {
                    final item = flashcards[index];

                    return FlashcardListItem(
                      key: UniqueKey(),
                      index: index,
                      flashcard: item,
                      flashcardKey: widget.groupName,
                      onDelete: () => _removeFromGroup(index),
                      onUpdate: () => _updateFlashcard(index),
                    );
                  }),
            );
          },
        ),
      ),
      extendBody: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        tooltip: 'Add',
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        // color: Theme.of(context).colorScheme.primary,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: Consumer<DatabaseModel>(builder: (context, db, _) {
          if (_isLoading) {
            return const Padding(
              padding:
                  EdgeInsets.only(bottom: 10, top: 40, left: 100, right: 100),
              child: LinearProgressIndicator(),
            );
          }

          final flashcards = db.flashcards;

          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                tooltip: "Learn",
                onPressed: (flashcards.isNotEmpty)
                    ? () => _showPresentationPage(context, flashcards)
                    : null,
                icon: const Icon(
                  Icons.present_to_all,
                  // color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              addSpacing(width: 30),
              IconButton(
                tooltip: "Exam",
                onPressed: (flashcards.isNotEmpty)
                    ? () => _showExamPage(context, flashcards)
                    : null,
                icon: const Icon(
                  Icons.play_arrow_rounded,
                  // color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
            ],
          );
        }),
      ),
    );
  }
}

class FlashcardListItem extends StatefulWidget {
  const FlashcardListItem(
      {super.key,
      required this.index,
      required this.flashcard,
      required this.flashcardKey,
      required this.onDelete,
      required this.onUpdate});

  final Flashcard flashcard;
  final String flashcardKey;
  final int index;
  final VoidCallback onDelete;
  final Function() onUpdate;

  @override
  State<FlashcardListItem> createState() => _FlashcardListItemState();
}

class _FlashcardListItemState extends State<FlashcardListItem> {
  bool editable = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _questionField;
  late TextEditingController _answerField;

  @override
  void initState() {
    _questionField = TextEditingController(text: widget.flashcard.question);
    _answerField = TextEditingController(text: widget.flashcard.answer);
    super.initState();
  }

  @override
  void dispose() {
    _questionField.dispose();
    _answerField.dispose();
    super.dispose();
  }

  Icon _editableIcon() {
    return (editable) ? const Icon(Icons.save) : const Icon(Icons.edit);
  }

  Future<void> _updateFlashcard() async {
    setState(() {
      widget.flashcard.question = _questionField.text;
      widget.flashcard.answer = _answerField.text;
    });

    await widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(child: Text((widget.index + 1).toString())),
            ),
            const VerticalDivider(),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 1.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _questionField,
                        enabled: editable,
                        decoration: const InputDecoration(
                            hintText: "Question",
                            contentPadding: EdgeInsets.only(left: 5)),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter some question";
                          }
                          return null;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: TextFormField(
                          controller: _answerField,
                          enabled: editable,
                          decoration: const InputDecoration(
                              hintText: "Answer",
                              contentPadding: EdgeInsets.only(left: 5)),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter some answer";
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const VerticalDivider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  IconButton(
                    icon: _editableIcon(),
                    onPressed: () {
                      setState(() {
                        if (!editable) {
                          editable = !editable;
                        } else if (editable &&
                            _formKey.currentState!.validate()) {
                          _updateFlashcard();
                          editable = !editable;
                        }
                      });
                    },
                  ),
                  addSpacing(height: 10),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      widget.onDelete();
                    },
                  ),
                ],
              ),
            )
          ],
        ));
  }
}

class ReorderableFlashcardItem extends StatelessWidget {
  const ReorderableFlashcardItem(
      {super.key,
      required this.flashcard,
      required this.index,
      this.elevation});

  final Flashcard flashcard;
  final int index;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: elevation ?? Theme.of(context).cardTheme.elevation,
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(child: Text((index + 1).toString())),
            ),
            const VerticalDivider(),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 1.0),
                child: Column(
                  children: [
                    TextFormField(
                      enabled: false,
                      initialValue: flashcard.question,
                      decoration: const InputDecoration(
                          hintText: "Question",
                          contentPadding: EdgeInsets.only(left: 5)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: TextFormField(
                        initialValue: flashcard.answer,
                        enabled: false,
                        decoration: const InputDecoration(
                            hintText: "Answer",
                            contentPadding: EdgeInsets.only(left: 5)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const VerticalDivider(),
            const Padding(
              padding: EdgeInsets.all(27.0),
            )
          ],
        ));
  }
}
