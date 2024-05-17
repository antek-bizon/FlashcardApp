import 'dart:math';
import 'package:flutter/material.dart';

class JsonCache {
  List<List>? _data;
  JsonCache({List<List>? init}) : _data = init;

  bool get isValid => _data != null;
  List<List> get data => _data!;

  set data(List<List> data) {
    _data = data;
  }

  void invalidate() {
    _data = null;
  }
}

class StylesList {
  final List<int> _cells;
  final JsonCache _jsonCache = JsonCache();
  static int defaultGenerator(int _) => 0;

  StylesList(List<int>? cells) : _cells = cells ?? [];

  StylesList.generate(int length)
      : _cells = List.generate(length, defaultGenerator);

  factory StylesList.fromRanges(List<List> data, int length) {
    if (data.isEmpty) {
      return StylesList.generate(length);
    }
    var list = <int>[];

    int start = data[0][0];
    int rangeLength = data[0][1];
    String value = data[0][2];
    list.addAll(List.generate(start, defaultGenerator));
    list.addAll(List.generate(rangeLength, (_) {
      final a = int.parse(value, radix: 36);
      if (a >= ColorfulTextEditingController.colors.length) {
        return 1;
      }
      return a;
    }));

    for (int i = 1; i < data.length; i++) {
      final range = data[i];
      list.addAll(List.generate(range[0], (_) {
        final a = int.parse(range[1], radix: 36);
        if (a >= ColorfulTextEditingController.colors.length) {
          return 1;
        }
        return a;
      }));
    }

    if (list.length < length) {
      list.addAll(List.generate(length - list.length, defaultGenerator));
    }

    return StylesList(list);
  }

  bool get isEmpty => _cells.isEmpty;
  bool get isNotEmpty => _cells.isNotEmpty;
  int get length => _cells.length;

  int operator [](int index) {
    return _cells[index];
  }

  TextSpan toTextSpan(BuildContext context, String text, {TextStyle? style}) {
    final alpha = style?.color?.alpha ?? 255;
    final textSpans = <InlineSpan>[];
    int start = 0;
    for (final group in _getGroups()) {
      final color = ((group.id != 0)
          ? Color.lerp(ColorfulTextEditingController.colors[group.id],
                  style?.color, 0.1)
              ?.withAlpha(alpha)
          : style?.color);

      final groupStyle = TextStyle(
        color: color,
      );
      //     fontFamily: style
      //         ?.fontFamily); // Theme.of(context).textTheme.bodyLarge?.fontFamily);

      // print(groupStyle);

      textSpans.add(TextSpan(
        text: text.substring(start, start + group.length),
        style: groupStyle,
      ));
      start += group.length;
    }
    return TextSpan(style: style, children: textSpans);
  }

  List<_StyleFragment> _getGroups() {
    final groups = <_StyleFragment>[];
    if (_cells.isNotEmpty) {
      int prev = _cells[0];
      int length = 1;
      for (int i = 1; i < _cells.length; i++) {
        if (_cells[i] != prev) {
          groups.add(_StyleFragment(id: prev, length: length));
          prev = _cells[i];
          length = 0;
        }
        length += 1;
      }
      groups.add(_StyleFragment(id: prev, length: length));
    }
    return groups;
  }

  List<List> toJson() {
    if (_jsonCache.isValid) {
      return _jsonCache.data;
    }

    final list = <List>[];
    int rangeStart = 0;
    int rangeLength = 0;
    int lastStyleValue = 0;
    int i = 0;
    bool startPoint = true;
    bool firstElement = true;
    for (final style in _cells) {
      if (style != lastStyleValue) {
        if (startPoint) {
          rangeStart = i;
          startPoint = false;
        } else if (firstElement) {
          list.add([rangeStart, rangeLength, lastStyleValue.toRadixString(36)]);
          firstElement = false;
        } else {
          list.add([rangeLength, lastStyleValue.toRadixString(36)]);
        }
        lastStyleValue = style;
        rangeLength = 1;
      } else {
        rangeLength++;
      }
      i++;
    }
    if (!startPoint) {
      if (firstElement) {
        list.add([rangeStart, rangeLength, lastStyleValue.toRadixString(36)]);
        firstElement = false;
      } else {
        list.add([rangeLength, lastStyleValue.toRadixString(36)]);
      }
    }
    _jsonCache.data = list;
    return list;
  }

  void setRange(int start, int end, Iterable<int> iter) {
    _cells.setRange(start, end, iter);
    _jsonCache.invalidate();
  }

  void insertAll(int index, Iterable<int> iter) {
    _cells.insertAll(index, iter);
    _jsonCache.invalidate();
  }

  void removeRange(int start, int end) {
    _cells.removeRange(start, end);
    _jsonCache.invalidate();
  }

  void replaceRange(int start, int end, Iterable<int> iter) {
    _cells.replaceRange(start, end, iter);
    _jsonCache.invalidate();
  }

  void insert(int index, int element) {
    _cells.insert(index, element);
    _jsonCache.invalidate();
  }

  void add(int value) {
    _cells.add(value);
    _jsonCache.invalidate();
  }
}

class ColorfulTextEditingController extends TextEditingController {
  final StylesList _styles;
  static final List<Color> colors = [
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
  int _currentColorIndex = 0;

  ColorfulTextEditingController({super.text, StylesList? styles})
      : _styles = styles ?? StylesList.generate(text?.length ?? 0);

  int get _start => max(min(selection.baseOffset, selection.extentOffset), 0);
  int get _end => max(max(selection.baseOffset, selection.extentOffset), 0);

  StylesList get styles => _styles;
  int _listGenerator(int _) => _currentColorIndex;

  int? getCurrentColorIndex() {
    if (_styles.isEmpty || selection.isCollapsed) {
      return _currentColorIndex;
    }

    final start = _start;
    if (start >= _styles.length) {
      return _currentColorIndex;
    }

    final end = _end;
    final prev = _styles[start];

    for (int i = start + 1; i < end; i++) {
      if (prev != _styles[i]) {
        return null;
      }
    }

    return prev;
  }

  set currentColorIndex(int colorIndex) {
    _currentColorIndex = colorIndex;
    if (_styles.isNotEmpty) {
      _styles.setRange(
          _start, _end, List.generate(_end - _start, _listGenerator));
    }
    notifyListeners();
  }

  @override
  set value(TextEditingValue newValue) {
    if (newValue != value) {
      final lengthDiff = newValue.text.length - value.text.length;
      if (value.selection.isCollapsed) {
        if (lengthDiff > 0) {
          _styles.insertAll(value.selection.baseOffset,
              List.generate(lengthDiff, _listGenerator));
        } else if (lengthDiff < 0) {
          _styles.removeRange(newValue.selection.baseOffset,
              newValue.selection.baseOffset - lengthDiff);
        }
      } else if (newValue.selection.isCollapsed) {
        final start = _start;
        final end = _end;

        if (lengthDiff > 0) {
          _styles.replaceRange(
              start, end, List.generate(end - start, _listGenerator));
          for (int i = end; i < end + lengthDiff; i++) {
            if (i < _styles.length) {
              _styles.insert(i, 0);
            } else {
              _styles.add(0);
            }
          }
        } else if (lengthDiff < 0) {
          _styles.replaceRange(start, end,
              List.generate(end - start + lengthDiff, _listGenerator));
        } else {
          // Check if there are any differences between the old and new text
          bool isDifferent = false;
          for (int i = start; i < end; i++) {
            if (newValue.text[i] != value.text[i]) {
              isDifferent = true;
              break;
            }
          }
          // If there are differences, replace the fragments in the selection range
          // with new ones
          if (isDifferent) {
            _styles.replaceRange(
                start, end, List.generate(end - start, _listGenerator));
          }
        }
      }
    }

    assert(newValue.text.length == styles.length);
    super.value = newValue;
  }

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    return _styles.toTextSpan(context, value.text, style: style);
  }

  bool isDefaultColor() {
    return getCurrentColorIndex() == 0;
  }

  void resetColor() {
    currentColorIndex = 0;
  }
}

class _StyleFragment {
  final int id;
  final int length;
  _StyleFragment({required this.id, required this.length});
  @override
  String toString() {
    return "{id: $id, length: $length}";
  }
}
