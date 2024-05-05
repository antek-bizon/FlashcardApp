import 'package:flutter/material.dart';

class ColorfulTextEditingController extends TextEditingController {
  ColorfulTextEditingController({super.text});

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    return TextSpan(style: style, children: _parseText(text));
  }

  List<InlineSpan>? _parseText(String? text) {
    List<InlineSpan> spans = [];
    if (text == null) {
      return spans;
    }

    int currentIndex = 0;
    final RegExp regex = RegExp(r'<#([A-Fa-f0-9]{6})>(.*?)<>');

    for (final Match match in regex.allMatches(text)) {
      final color = Color(int.parse(match.group(1)!, radix: 16) | 0xFF000000);
      final content = match.group(2)!;

      //Add text before the match
      spans.add(TextSpan(
        text: text.substring(currentIndex, match.start),
      ));

      // Add text with color
      spans.add(
        TextSpan(
          text: content,
          style: TextStyle(color: color),
        ),
      );

      currentIndex = match.end;
    }

    // Add remaining text
    spans.add(TextSpan(
      text: text.substring(currentIndex),
    ));

    return spans;
  }

  @override
  set text(String newText) {
    value = value.copyWith(
      text: newText,
      selection: const TextSelection.collapsed(offset: -1),
      composing: TextRange.empty,
    );
  }

  @override
  set value(TextEditingValue newValue) {
    final newText = newValue.text;
    final cursorPos = newValue.selection.baseOffset;

    if (newText.contains('<') || newText.contains('>')) {
      final int openTagIndex = newText.lastIndexOf('<', cursorPos - 1);
      final int closeTagIndex = newText.indexOf('>', cursorPos);

      if (openTagIndex != -1 &&
          closeTagIndex != -1 &&
          openTagIndex < closeTagIndex) {
        final updatedCursorPos = closeTagIndex + 1;
        final updatedSelection =
            TextSelection.collapsed(offset: updatedCursorPos);

        super.value = newValue.copyWith(selection: updatedSelection);
        return;
      }
    }

    super.value = newValue;
  }
}
