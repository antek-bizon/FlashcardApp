import 'dart:async';

import 'package:flutter/material.dart';

import 'color_picker.dart';
import 'spannable_style.dart';
import 'spannable_text.dart';

const defaultColors = [
  Colors.black,
  Colors.red,
  Colors.redAccent,
  Colors.orange,
  Colors.orangeAccent,
  Colors.yellow,
  Colors.yellowAccent,
  Colors.green,
  Colors.greenAccent,
  Colors.blue,
  Colors.blueAccent,
  Colors.indigo,
  Colors.indigoAccent,
  Colors.purple,
  Colors.purpleAccent,
  Colors.grey,
];

class StyleToolbar extends StatefulWidget {
  final SpannableTextEditingController controller;

  const StyleToolbar({
    super.key,
    required this.controller,
  });

  @override
  State<StyleToolbar> createState() => _StyleToolbarState();
}

class _StyleToolbarState extends State<StyleToolbar> {
  final StreamController<TextEditingValue> _streamController =
      StreamController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      _streamController.sink.add(widget.controller.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TextEditingValue>(
      stream: _streamController.stream,
      builder: (context, snapshot) {
        var currentStyle = SpannableStyle();
        TextSelection? currentSelection;
        if (snapshot.hasData) {
          var value = snapshot.requireData;
          var selection = value.selection;
          if (!selection.isCollapsed) {
            currentSelection = selection;
            var temp = widget.controller.getSelectionStyle();
            if (temp != null) {
              currentStyle = temp;
            }
          } else {
            currentStyle = widget.controller.composingStyle;
          }
        }
        return Row(
          children: [
            ..._buildActions(
              currentStyle,
              currentSelection,
            ),
            IconButton(
              icon: const Icon(
                Icons.format_color_text,
              ),
              onPressed: () async {
                FocusScope.of(context).unfocus();
                ColorSelection colorSelection = await showModalBottomSheet(
                  context: context,
                  builder: (context) => ColorPicker(
                    colors: defaultColors,
                    selectionColor: getColorFromValue(
                      currentStyle.foregroundColor,
                    ),
                  ),
                );
                _setTextColor(
                  currentStyle,
                  useForegroundColor,
                  colorSelection,
                  selection: currentSelection,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: widget.controller.canUndo()
                  ? () {
                      widget.controller.undo();
                      FocusScope.of(context).unfocus();
                    }
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.redo),
              onPressed: widget.controller.canRedo()
                  ? () {
                      widget.controller.redo();
                      FocusScope.of(context).unfocus();
                    }
                  : null,
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  List<Widget> _buildActions(
      SpannableStyle spannableStyle, TextSelection? selection) {
    final Map<int, IconData> styleMap = {
      styleBold: Icons.format_bold,
      styleItalic: Icons.format_italic,
      styleUnderline: Icons.format_underlined,
      styleLineThrough: Icons.format_strikethrough,
    };

    return styleMap.keys
        .map((style) => IconButton(
              icon: Icon(
                styleMap[style],
                color: spannableStyle.hasStyle(style)
                    ? Theme.of(context).colorScheme.secondary
                    : null,
              ),
              onPressed: () => _toggleTextStyle(
                spannableStyle.copy(),
                style,
                selection: selection,
              ),
            ))
        .toList();
  }

  void _toggleTextStyle(
    SpannableStyle spannableStyle,
    int textStyle, {
    TextSelection? selection,
  }) {
    bool hasSelection = selection != null;
    if (spannableStyle.hasStyle(textStyle)) {
      if (hasSelection) {
        widget.controller
            .setSelectionStyle((style) => style..clearStyle(textStyle));
      } else {
        widget.controller.composingStyle = spannableStyle
          ..clearStyle(textStyle);
      }
    } else {
      if (hasSelection) {
        widget.controller
            .setSelectionStyle((style) => style..setStyle(textStyle));
      } else {
        widget.controller.composingStyle = spannableStyle..setStyle(textStyle);
      }
    }
  }

  void _setTextColor(
    SpannableStyle spannableStyle,
    int textStyle,
    ColorSelection colorSelection, {
    TextSelection? selection,
  }) {
    bool hasSelection = selection != null;
    if (hasSelection) {
      if (textStyle == useForegroundColor) {
        widget.controller.selection = selection;
        widget.controller.setSelectionStyle(
          (style) => style..setForegroundColor(colorSelection.color),
        );
      }
    } else {
      if (textStyle == useForegroundColor) {
        widget.controller.composingStyle = spannableStyle
          ..setForegroundColor(colorSelection.color);
      }
    }
  }
}
