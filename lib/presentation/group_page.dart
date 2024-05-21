import 'package:flashcards/cubits/flashcards.dart';
import 'package:flashcards/cubits/groups.dart';
import 'package:flashcards/presentation/exam_page.dart';
import 'package:flashcards/presentation/widgets/add_dialog.dart';
import 'package:flashcards/data/models/flashcard.dart';
import 'package:flashcards/presentation/presentation_page.dart';
import 'package:flashcards/presentation/widgets/flashcard_list_item.dart';
import 'package:flashcards/utils.dart';
import 'package:flashcards/presentation/widgets/default_body.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum MenuItem {
  //  reorder,
  deleteGroup
}

enum PresentationButtonOptions { none, shuffle }

class GroupPage extends StatefulWidget {
  final String groupName;
  final String? groupId;

  const GroupPage({super.key, required this.groupName, this.groupId});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  @override
  void initState() {
    super.initState();

    context
        .read<CardCubit>()
        .getFlashcards(authState(context), widget.groupName, widget.groupId);
  }

  void _onMenuSelected(MenuItem option, BuildContext context) {
    switch (option) {
      // case MenuItem.reorder:
      //   setState(() {
      //     _reorderList = !_reorderList;
      //   });
      //   break;
      case MenuItem.deleteGroup:
        context
            .read<GroupCubit>()
            .removeGroup(authState(context), widget.groupName, widget.groupId);
        Navigator.of(context).pop();
        break;
      default:
        break;
    }
  }

  void _showAddDialog(BuildContext context) {
    // _endReoreder();
    showDialog<String>(
      context: context,
      builder: (BuildContext context) =>
          BlocBuilder<CardCubit, CardState>(builder: (context, state) {
        if (state is SuccessCardState) {
          return AddFlashcardDialog(
            onAdd: (item, image) => context.read<CardCubit>().addFlashcard(
                authState: authState(context),
                groupName: widget.groupName,
                groupId: widget.groupId,
                item: item,
                image: image),
            existingFlashcards: state.flashcards,
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      }),
    );
  }

  void _showPresentationPage(
      BuildContext context, List<FlashcardModel> flashcardGroup) {
    // _endReoreder();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PresentationPage(flashcards: flashcardGroup)),
    );
  }

  void _showExamPage(
      BuildContext context, List<FlashcardModel> flashcardGroup) {
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.groupName),
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
          child: BlocConsumer<CardCubit, CardState>(
        builder: (context, state) {
          if (state is SuccessCardState) {
            final flashcards = state.flashcards;
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
                    final cubit = context.read<CardCubit>();

                    return FlashcardListItem(
                      key: UniqueKey(),
                      index: index,
                      flashcard: item,
                      flashcardKey: widget.groupName,
                      onDelete: () => cubit.removeFlashcard(authState(context),
                          widget.groupName, index, widget.groupId != null),
                      onUpdate: () => cubit.updateFlashcard(authState(context),
                          widget.groupName, index, widget.groupId),
                    );
                  }),
            );
          } else if (state is ErrorCardState) {
            if (kDebugMode) {
              print("Error in group page: ${state.message}");
            }
            return const Center(
              child: Text("Error has occured. Please try again."),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
        listener: (context, state) {},
      )),
      extendBody: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        tooltip: 'Add',
        heroTag: '_FlashcardGroupPageState',
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        // color: Theme.of(context).colorScheme.primary,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: BlocBuilder<CardCubit, CardState>(
          builder: (context, state) {
            if (state is SuccessCardState) {
              final flashcards = state.flashcards;

              return Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  PopupMenuButton(
                    enabled: flashcards.isNotEmpty,
                    onSelected: (value) {
                      final list = List.generate(flashcards.length,
                          (index) => FlashcardModel.copy(flashcards[index]));
                      if (value == PresentationButtonOptions.shuffle) {
                        list.shuffle();
                      }
                      _showPresentationPage(context, list);
                    },
                    icon: const Icon(
                      Icons.present_to_all,
                    ),
                    itemBuilder: (context) =>
                        <PopupMenuEntry<PresentationButtonOptions>>[
                      const PopupMenuItem<PresentationButtonOptions>(
                        value: PresentationButtonOptions.none,
                        child: Text("Original order"),
                      ),
                      const PopupMenuItem<PresentationButtonOptions>(
                        value: PresentationButtonOptions.shuffle,
                        child: Text("Random order"),
                      ),
                    ],
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
            } else {
              return const Center(child: LinearProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}

class ReorderableFlashcardItem extends StatelessWidget {
  const ReorderableFlashcardItem(
      {super.key,
      required this.flashcard,
      required this.index,
      this.elevation});

  final FlashcardModel flashcard;
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
