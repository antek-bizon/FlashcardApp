import 'package:flashcards/cubits/quiz_items.dart';
import 'package:flashcards/data/models/quiz_group.dart';
import 'package:flashcards/presentation/widgets/dropdown_image.dart';
import 'package:flashcards/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuizListItemBody extends StatefulWidget {
  final int index;
  final QuizGroup group;
  final Widget child;
  final String? imageUri;
  final (bool, String?) Function(bool) onEdit;
  const QuizListItemBody({
    super.key,
    required this.index,
    required this.group,
    required this.child,
    required this.imageUri,
    required this.onEdit,
  });

  @override
  State<QuizListItemBody> createState() => _QuizListItemBodyState();
}

class _QuizListItemBodyState extends State<QuizListItemBody> {
  bool _editable = false;
  String? _errorMessage;

  Icon _editableIcon() {
    return (_editable) ? const Icon(Icons.save) : const Icon(Icons.edit);
  }

  @override
  Widget build(BuildContext context) {
    final image = getImage(widget.imageUri);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: CircleAvatar(child: Text((widget.index + 1).toString())),
              ),
              const VerticalDivider(),
              Expanded(
                child: widget.child,
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
                          final (isEditable, errorMessage) =
                              widget.onEdit(_editable);
                          if (isEditable != _editable && !isEditable) {
                            context.read<QuizItemCubit>().updateQuizItem(
                                authState(context), widget.group, widget.index);
                          }
                          _editable = isEditable;
                          _errorMessage = errorMessage;
                        });
                      },
                    ),
                    addSpacing(height: 10),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _onDelete(context),
                    ),
                  ],
                ),
              )
            ],
          ),
          Visibility(
              visible: _errorMessage != null,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 35.0),
                child: Text(
                  _errorMessage ?? "",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.error),
                ),
              )),
          if (image != null)
            DropdownImage(
              image: image,
            )
        ],
      ),
    );
  }

  void _onDelete(BuildContext context) {
    context
        .read<QuizItemCubit>()
        .removeQuizItem(authState(context), widget.group, widget.index);
  }
}
