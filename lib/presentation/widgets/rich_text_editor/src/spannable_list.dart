import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'spannable_style.dart';

typedef ModifyCallback = SpannableStyle Function(SpannableStyle style);

class SpannableList {
  late List<SpannableStyle> _list;
  List<List>? jsonCache;

  List<SpannableStyle> get list => _list;

  SpannableList(List<SpannableStyle> list) : _list = list;

  factory SpannableList.fromRanges(List<List> data, int length) {
    try {
      if (data.isNotEmpty) {
        var list = <SpannableStyle>[];

        int start = data[0][0];
        int rangeLength = data[0][1];
        String value = data[0][2];
        list.addAll(List.generate(start, (index) => SpannableStyle()));
        list.addAll(List.generate(rangeLength,
            (index) => SpannableStyle(value: int.parse(value, radix: 36))));

        for (int i = 1; i < data.length; i++) {
          final range = data[i];
          list.addAll(List.generate(
              range[0],
              (index) =>
                  SpannableStyle(value: int.parse(range[1], radix: 36))));
        }

        assert(list.length == length);

        return SpannableList(list);
      }
      return SpannableList.generate(length);
    } catch (ex) {
      if (kDebugMode) {
        print("Error in SpannableList.fromRanges: $ex");
      }
      return SpannableList.generate(length);
    }
  }

  factory SpannableList.fromStringList(List<String> list) {
    return SpannableList(_fromStringList(list));
  }

  factory SpannableList.fromJson(String styleJson, int length) {
    try {
      return SpannableList(_fromJson(styleJson));
    } catch (ex) {
      return SpannableList.generate(length);
    }
  }

  static List<SpannableStyle> _fromJson(String styleJson) {
    var list = json.decode(styleJson);
    return list
        .map((e) => SpannableStyle(value: int.parse(e, radix: 36)))
        .toList();
  }

  static List<SpannableStyle> _fromStringList(List<String> list) {
    return list
        .map((e) => SpannableStyle(value: int.parse(e, radix: 36)))
        .toList();
  }

  SpannableList.generate(int length) {
    _list = List.generate(length, (index) => SpannableStyle(value: 0),
        growable: true);
  }

  void _invalidateCache() {
    jsonCache = null;
  }

  void insert(int offset, SpannableStyle style) {
    _list.insert(offset, style);
    _invalidateCache();
  }

  void delete(int offset) {
    _list.removeAt(offset);
    _invalidateCache();
  }

  SpannableStyle index(int offset) => _list[offset];

  void modify(int offset, ModifyCallback callback) {
    _list[offset] = callback(index(offset));
    _invalidateCache();
  }

  void concat(SpannableList anotherList) {
    _list.addAll(anotherList.list);
    _invalidateCache();
  }

  SpannableList copy() {
    return SpannableList(_list.map((e) => e.copy()).toList());
  }

  void clear() {
    _list.clear();
    _invalidateCache();
  }

  int get length => _list.length;

  // String toJson() {
  //   return json
  //       .encode(_list.map((style) => style.value.toRadixString(36)).toList());
  // }

  List<List> toJson() {
    if (jsonCache != null) {
      return jsonCache!;
    }

    final list = <List>[];
    int rangeStart = 0;
    int rangeLength = 0;
    int lastStyleValue = 0;
    int i = 0;
    bool startPoint = true;
    bool firstElement = true;
    for (final style in _list) {
      if (style.value != lastStyleValue) {
        if (startPoint) {
          rangeStart = i;
          startPoint = false;
        } else if (firstElement) {
          list.add([rangeStart, rangeLength, lastStyleValue.toRadixString(36)]);
          firstElement = false;
        } else {
          list.add([rangeLength, lastStyleValue.toRadixString(36)]);
        }
        lastStyleValue = style.value;
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
    jsonCache = list;
    return list;
    //print(list);
    //return _list.map((style) => style.value.toRadixString(36)).toList();
  }

  TextSpan toTextSpan(String text, {required TextStyle defaultStyle}) {
    var children = <InlineSpan>[];
    if (length > 0) {
      var groupList = _getGroupList();
      for (var group in groupList) {
        var childSpan = TextSpan(
          style: _buildStyle(group.style),
          text: text.substring(group.start, group.start + group.length),
        );
        children.add(childSpan);
      }
    }
    return TextSpan(
      style: defaultStyle,
      children: children,
    );
  }

  TextStyle _buildStyle(SpannableStyle style) {
    var decoration = TextDecoration.combine([
      if (style.hasStyle(styleUnderline)) TextDecoration.underline,
      if (style.hasStyle(styleLineThrough)) TextDecoration.lineThrough,
    ]);

    Color? foregroundColor;
    if (style.hasStyle(useForegroundColor)) {
      foregroundColor = getColorFromValue(style.foregroundColor);
    }

    Color? backgroundColor;
    if (style.hasStyle(useBackgroundColor)) {
      backgroundColor = getColorFromValue(style.backgroundColor);
    }

    return TextStyle(
      color: foregroundColor,
      backgroundColor: backgroundColor,
      fontWeight: style.hasStyle(styleBold) ? FontWeight.bold : null,
      fontStyle: style.hasStyle(styleItalic) ? FontStyle.italic : null,
      decoration: decoration,
    );
  }

  List<_SpannableStyleGroup> _getGroupList() {
    var groupList = List<_SpannableStyleGroup>.empty(growable: true);
    var temp = SpannableStyle();
    int start = 0;
    for (var offset = 0; offset <= length; offset++) {
      if (offset == length) {
        groupList.add(_SpannableStyleGroup(
          style: temp,
          start: start,
          length: offset - start,
        ));
        break;
      }

      var element = index(offset);
      if (temp != element) {
        groupList.add(_SpannableStyleGroup(
          style: temp,
          start: start,
          length: offset - start,
        ));
        start = offset;
        temp = element;
      }
    }
    return groupList;
  }

  @override
  String toString() {
    return '$runtimeType(_list: $_list)';
  }
}

class _SpannableStyleGroup {
  final SpannableStyle style;
  final int start;
  final int length;

  _SpannableStyleGroup({
    required this.style,
    required this.start,
    required this.length,
  });

  @override
  String toString() {
    return '$runtimeType(style: $style, start: $start, length: $length)';
  }
}
