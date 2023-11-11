import 'package:flutter/material.dart';

class DefaultBody extends StatelessWidget {
  const DefaultBody({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final image = (Theme.of(context).brightness == Brightness.light)
        ? 'assets/flower.jpg'
        : 'assets/flower_dark.jpg';

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
      ),
      child: child,
    );
  }
}
