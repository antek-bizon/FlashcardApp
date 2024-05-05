import 'package:flutter/material.dart';

typedef ColorSelectCallback = void Function(Color);

class ColorPicker extends StatelessWidget {
  final List<Color> colors;
  final double itemSize;
  final Color selectionColor;

  const ColorPicker({
    super.key,
    required this.colors,
    required this.selectionColor,
    this.itemSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _ColorContainer(
            colors: colors,
            itemSize: itemSize,
            selectionColor: selectionColor,
            onColorSelected: (color) {
              Navigator.pop(context, ColorSelection(color));
            },
          ),
        ),
      ],
    );
  }
}

class _ColorContainer extends StatelessWidget {
  final List<Color> colors;
  final double itemSize;
  final Color selectionColor;
  final ColorSelectCallback onColorSelected;

  const _ColorContainer({
    required this.colors,
    required this.selectionColor,
    required this.itemSize,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.extent(
      shrinkWrap: true,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      maxCrossAxisExtent: itemSize,
      children: colors
          .map((color) => _ColorButton(
                color: color,
                selected: color.value == selectionColor.value,
                onTap: () => onColorSelected(color),
              ))
          .toList(),
    );
  }
}

class _ColorButton extends StatelessWidget {
  final Color? color;
  final VoidCallback onTap;
  final bool selected;

  const _ColorButton({
    this.color,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    return Stack(
      children: <Widget>[
        Material(
          color: color ?? themeData.textTheme.bodyMedium!.color!,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
          ),
        ),
        Visibility(
          visible: selected,
          child: Container(
            decoration: BoxDecoration(
              color: themeData.dividerColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.check,
              color: color != null
                  ? Colors.white
                  : themeData.brightness == Brightness.light
                      ? Colors.white
                      : Colors.black,
            ),
          ),
        )
      ],
    );
  }
}

@immutable
class ColorSelection {
  final Color color;

  const ColorSelection(this.color);

  @override
  String toString() {
    return '_ColorSelection(color: $color)';
  }
}
