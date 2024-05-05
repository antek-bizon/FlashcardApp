import 'package:flutter/material.dart';

class DefaultBody extends StatelessWidget {
  const DefaultBody({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final image = (Theme.of(context).brightness == Brightness.light)
        ? 'assets/flower.jpg'
        : 'assets/flower_dark.jpg';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: Container(
        key: ValueKey(image),
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
        ),
        child: child,
      ),
    );
  }
}
