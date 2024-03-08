import 'package:flutter/material.dart';

class DropdownImage extends StatefulWidget {
  final Widget image;

  const DropdownImage({super.key, required this.image});

  @override
  State<DropdownImage> createState() => _DropdownImageState();
}

class _DropdownImageState extends State<DropdownImage> {
  bool _isDown = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        children: [
          Visibility(
            visible: _isDown,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: widget.image,
            ),
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  _isDown = !_isDown;
                });
              },
              icon: Icon((_isDown)
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded))
        ],
      ),
    );
  }
}
