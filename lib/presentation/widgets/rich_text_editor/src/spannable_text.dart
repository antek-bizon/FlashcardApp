import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flashcards/presentation/widgets/rich_text_editor/diff_patch_match/diff_match_patch.dart';

import 'spannable_list.dart';
import 'spannable_style.dart';

typedef SetStyleCallback = SpannableStyle Function(SpannableStyle style);

class SpannableTextEditingController extends TextEditingController {
  final int historyLength;

  late SpannableList _currentStyleList;
  late SpannableStyle _currentComposingStyle;

  final Queue<ControllerHistory> _histories = Queue();
  final Queue<ControllerHistory> _undoHistories = Queue();

  bool _updatedByHistory = false;

  SpannableTextEditingController({
    String text = '',
    SpannableList? styleList,
    SpannableStyle? composingStyle,
    this.historyLength = 5,
  }) : super(text: text) {
    _currentStyleList = styleList ?? SpannableList.generate(text.length);
    _currentComposingStyle = composingStyle ?? SpannableStyle();
  }

  SpannableTextEditingController.empty({this.historyLength = 5})
      : super(text: '') {
    _currentStyleList = SpannableList.generate(0);
    _currentComposingStyle = SpannableStyle();
  }

  SpannableTextEditingController.fromJson({
    String text = '',
    String? styleJson,
    SpannableStyle? composingStyle,
    this.historyLength = 5,
  }) : super(text: text) {
    _currentStyleList = (styleJson != null && styleJson.isNotEmpty)
        ? SpannableList.fromJson(styleJson, text.length)
        : SpannableList.generate(text.length);
    _currentComposingStyle = composingStyle ?? SpannableStyle();
  }

  @override
  set value(TextEditingValue newValue) {
    if (value.text != newValue.text) {
      if (!_updatedByHistory) {
        _updateHistories(_histories);
        _undoHistories.clear();
        _updateList(value.text, newValue.text);
      }
      _updatedByHistory = false;
    }
    super.value = newValue;
  }

  // @override
  // TextSpan buildTextSpan(
  //     {required TextStyle style, required bool withComposing}) {
  //   return _currentStyleList.toTextSpan(text, defaultStyle: style);
  // }

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    // if (_currentStyleList.length < text.length) {
    //   _currentStyleList.insert(text.length, SpannableStyle());
    // }
    return _currentStyleList.toTextSpan(text,
        defaultStyle: style ?? const TextStyle());
  }

  SpannableList get styleList => _currentStyleList.copy();

  SpannableStyle get composingStyle => _currentComposingStyle.copy();

  set composingStyle(SpannableStyle newComposingStyle) {
    _currentComposingStyle = newComposingStyle;
    notifyListeners();
  }

  void setSelectionStyle(SetStyleCallback callback) {
    if (selection.isValid && selection.isNormalized) {
      _updateHistories(_histories);
      for (var offset = selection.start; offset < selection.end; offset++) {
        _currentStyleList.modify(offset, callback);
      }
      notifyListeners();
    }
  }

  SpannableStyle? getSelectionStyle() {
    if (selection.isValid && selection.isNormalized) {
      SpannableStyle style = SpannableStyle();

      var start = selection.start;
      var end = selection.end;
      var first = _currentStyleList.index(start);

      var foregroundColor =
          first.hasStyle(useForegroundColor) ? first.foregroundColor : null;
      var backgroundColor =
          first.hasStyle(useBackgroundColor) ? first.backgroundColor : null;

      for (var offset = start; offset < end; offset++) {
        final current = _currentStyleList.index(offset);
        style.setStyle(style.style | current.style);

        if (foregroundColor != null &&
            foregroundColor != current.foregroundColor) {
          foregroundColor = null;
        }
        if (backgroundColor != null &&
            backgroundColor != current.backgroundColor) {
          backgroundColor = null;
        }
      }
      if (foregroundColor != null) {
        style.setForegroundColor(getColorFromValue(foregroundColor));
      }
      if (backgroundColor != null) {
        style.setBackgroundColor(getColorFromValue(backgroundColor));
      }
      return style;
    }
    return null;
  }

  void clearComposingStyle() {
    _currentComposingStyle = SpannableStyle();
  }

  bool canUndo() => _histories.isNotEmpty;

  void undo() {
    assert(canUndo());
    _updateHistories(_undoHistories);
    _applyHistory(_histories.removeLast());
  }

  bool canRedo() => _undoHistories.isNotEmpty;

  void redo() {
    assert(canRedo());
    _updateHistories(_histories);
    _applyHistory(_undoHistories.removeLast());
  }

  void _applyHistory(ControllerHistory history) {
    _updatedByHistory = true;
    _currentStyleList = history.styleList;
    value = history.value;
  }

  void _updateHistories(Queue<ControllerHistory> histories) {
    if (histories.length == historyLength) {
      histories.removeFirst();
    }
    histories.add(ControllerHistory(
      value: value,
      styleList: _currentStyleList.copy(),
    ));
  }

  void _updateList(String oldText, String newText) {
    var textChange = _calculateTextChange(oldText, newText);
    var diffLength = (oldText.length - newText.length).abs();
    if (diffLength > 0) {
      var composedStyle = composingStyle.copy();
      if (diffLength > 0) {
        for (var index = 0; index < diffLength; index++) {
          if (textChange.operation == Operation.insert) {
            _currentStyleList.insert(textChange.offset + index, composedStyle);
          } else if (textChange.operation == Operation.delete) {
            _currentStyleList.delete(textChange.offset);
          }
        }
      }
    }
  }

  _TextChange _calculateTextChange(String oldText, String newText) {
    var dmp = DiffMatchPatch();
    var diffList = dmp.diffMain(oldText, newText);
    Operation operation = Operation.delete;
    int length = 0;
    var offset = 0;
    for (var index = 0; index < diffList.length; index++) {
      final diff = diffList[index];
      if (diff.operation == Operation.equal) {
        offset += diff.text.length;
      } else if (diff.operation == Operation.insert) {
        if (index + 1 < diffList.length) {
          final nextDiff = diffList[index + 1];
          if (nextDiff.operation == Operation.delete) {
            if (nextDiff.text.length == diff.text.length) break;
            if (nextDiff.text.length < diff.text.length) {
              operation = Operation.delete;
              length = diff.text.length - nextDiff.text.length;
              break;
            }
          }
        }
        operation = Operation.insert;
        length = diff.text.length;
        break;
      } else if (diff.operation == Operation.delete) {
        if (index + 1 < diffList.length) {
          final nextDiff = diffList[index + 1];

          if (nextDiff.operation == Operation.insert) {
            if (nextDiff.text.length == diff.text.length) break;
            if (nextDiff.text.length > diff.text.length) {
              offset++;
              operation = Operation.insert;
              length = nextDiff.text.length - diff.text.length;
              break;
            }
          }
        }
        operation = Operation.delete;
        length = diff.text.length;
        break;
      }
    }

    return _TextChange(operation, offset, length);
  }
}

@immutable
class ControllerHistory {
  final TextEditingValue value;
  final SpannableList styleList;

  const ControllerHistory({
    required this.value,
    required this.styleList,
  });

  @override
  String toString() {
    return '_ControllerHistory(text: ${value.text}, styleList: $styleList)';
  }
}

@immutable
class _TextChange {
  final Operation operation;
  final int offset;
  final int length;

  const _TextChange(this.operation, this.offset, this.length);

  @override
  String toString() {
    return '$runtimeType(operation: $operation, offset: $offset, length: $length)';
  }
}
