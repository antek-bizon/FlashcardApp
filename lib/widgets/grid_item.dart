import 'package:flutter/material.dart';

class GridItem extends StatelessWidget {
  const GridItem({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 15,
      child: Container(
        color: Colors.amber,
        padding: const EdgeInsets.all(5),
        child: Text(text),
      ),
    );
  }
}
