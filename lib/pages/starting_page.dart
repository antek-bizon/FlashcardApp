import 'dart:ui';
import 'package:flashcards/pages/my_home_page.dart';
import 'package:flashcards/widgets/default_body.dart';
import 'package:flutter/material.dart';

class StartingPage extends StatelessWidget {
  const StartingPage({
    super.key,
  });

  void openApp(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MyHomePage(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: DefaultBody(child: TitleButton(onOpenApp: openApp)));
  }
}

class TitleButton extends StatelessWidget {
  const TitleButton({super.key, required this.onOpenApp});
  final Function(BuildContext) onOpenApp;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onOpenApp(context),
      child: Center(
          child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 5),
          child: Container(
            color:
                Theme.of(context).colorScheme.secondaryContainer.withAlpha(100),
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Flashcards App",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize:
                          Theme.of(context).textTheme.displayMedium?.fontSize),
                ),
                Text(
                  "Click to open",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize:
                          Theme.of(context).textTheme.bodyLarge?.fontSize),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
