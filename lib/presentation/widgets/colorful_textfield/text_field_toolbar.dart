import 'dart:async';

import 'package:flutter/material.dart';
import 'color_selector.dart';
import 'colorful_text_editing_controller.dart';

class TextFieldToolbar extends StatefulWidget {
  final ColorfulTextEditingController controller;
  const TextFieldToolbar({super.key, required this.controller});

  @override
  State<TextFieldToolbar> createState() => _TextFieldToolbarState();
}

class _TextFieldToolbarState extends State<TextFieldToolbar> {
  final StreamController<TextEditingValue> _streamController =
      StreamController();
  late VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _listener = () {
      _streamController.sink.add(widget.controller.value);
    };
    widget.controller.addListener(_listener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TextEditingValue>(
        stream: _streamController.stream,
        builder: (context, snapshot) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.format_color_text,
                ),
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  int? colorIndex = await showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      final index = widget.controller.getCurrentColorIndex();

                      return ColorPicker(
                        colors: ColorfulTextEditingController.colors,
                        selectionColor: index != null
                            ? ColorfulTextEditingController.colors[index]
                            : null,
                      );
                    },
                  );
                  if (colorIndex == null) return;
                  widget.controller.currentColorIndex = colorIndex;
                },
              ),
              if (!widget.controller.isDefaultColor())
                IconButton(
                  icon: const Icon(Icons.format_color_reset),
                  onPressed: () => widget.controller.resetColor(),
                )
            ],
          );
        });
  }
}
