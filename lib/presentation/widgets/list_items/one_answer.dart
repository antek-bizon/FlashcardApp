import 'package:flashcards/data/models/one_answer.dart';
import 'package:flashcards/data/models/quiz_group.dart';
import 'package:flashcards/presentation/widgets/list_items/quiz_list_item.dart';
import 'package:flashcards/presentation/widgets/multi_line_text_field.dart';
import 'package:flutter/material.dart';

class OneAnswerListItem extends StatefulWidget {
  final int index;
  final OneAnswer item;
  final QuizGroup group;
  final String? imageUri;
  const OneAnswerListItem({
    super.key,
    required this.index,
    required this.item,
    required this.group,
    required this.imageUri,
  });

  @override
  State<OneAnswerListItem> createState() => _OneAnswerListItemState();
}

class _OneAnswerListItemState extends State<OneAnswerListItem> {
  bool _editable = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionField;
  final _scrollController = ScrollController();
  final List<TextEditingController> _controllers = [];
  int? _selectedAnswerIndex;

  @override
  void initState() {
    super.initState();
    _questionField = TextEditingController(text: widget.item.question);
    for (final answer in widget.item.answers) {
      _controllers.add(TextEditingController(text: answer));
    }
    _selectedAnswerIndex = widget.item.correctAnswer;
  }

  @override
  void dispose() {
    _questionField.dispose();
    _scrollController.dispose();
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  (bool, String?) _onEdit(bool wasEditable) {
    final errorMessage =
        (_selectedAnswerIndex == null) ? "Select correct answer" : null;
    if (wasEditable && _formKey.currentState!.validate()) {
      setState(() {
        widget.item.question = _questionField.text;
        widget.item.answers = _controllers.map((e) => e.text).toList();
        widget.item.correctAnswer = _selectedAnswerIndex!;

        _editable = false;
      });
      return (false, errorMessage);
    }
    if (!_editable) {
      setState(() {
        _editable = true;
      });
    }
    return (true, errorMessage);
  }

  void _removeAnswerField(int index) {
    setState(() {
      if (_selectedAnswerIndex != null && index == _selectedAnswerIndex) {
        _selectedAnswerIndex = null;
      } else if (_selectedAnswerIndex != null &&
          index < _selectedAnswerIndex!) {
        _selectedAnswerIndex = _selectedAnswerIndex! - 1;
      }
      _controllers.removeAt(index);
    });
  }

  void _addAnswerField() {
    setState(() {
      _controllers.add(TextEditingController());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(
        _scrollController.position.maxScrollExtent,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final disabledColor = Theme.of(context).disabledColor;

    return QuizListItemBody(
        index: widget.index,
        group: widget.group,
        imageUri: widget.imageUri,
        onEdit: _onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 1.0),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Column(
                children: [
                  MultiLineTextField(
                    enabled: _editable,
                    controller: _questionField,
                    labelText: "Question",
                    validatorText: "Please enter a question",
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.3),
                    child: ListView.builder(
                      controller: _scrollController,
                      shrinkWrap: true,
                      itemCount: _controllers.length,
                      itemBuilder: (context, index) {
                        final radio = _radio(index, disabledColor);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              radio,
                              // Radio<int>(
                              //   value: index,
                              //   groupValue: _selectedAnswerIndex,
                              //   onChanged: (int? value) {
                              //     setState(() {
                              //       _selectedAnswerIndex = value;
                              //     });
                              //   },
                              // ),
                              Expanded(
                                child: MultiLineTextField(
                                  enabled: _editable,
                                  controller: _controllers[index],
                                  labelText:
                                      'Answer ${String.fromCharCode(65 + index)}',
                                  validatorText:
                                      'Please enter answer ${String.fromCharCode(65 + index)}',
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle),
                                onPressed: (_editable)
                                    ? () => _removeAnswerField(index)
                                    : null,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: (_editable) ? () => _addAnswerField() : null,
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _radio(int index, Color disabledColor) {
    final radio = (!_editable)
        ? (index == _selectedAnswerIndex)
            ? Icon(
                Icons.check,
                color: disabledColor,
              )
            : Icon(Icons.minimize, color: disabledColor)
        : Radio<int>(
            value: index,
            groupValue: _selectedAnswerIndex,
            onChanged: (int? value) {
              setState(() {
                _selectedAnswerIndex = value;
              });
            },
          );
    return radio;
  }
}
