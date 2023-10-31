import 'package:flashcards/pages/my_home_page.dart';
import 'package:flashcards/utils.dart';
import 'package:flutter/material.dart';

class StartingPage extends StatelessWidget {
  const StartingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MyHomePage(),
              ));
        },
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              "Flashcards App",
              style: TextStyle(
                  fontSize:
                      Theme.of(context).textTheme.displayMedium?.fontSize),
            ),
            Text(
              "Click to open",
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize),
            ),
            addSpacing(height: 50)
          ],
        )),
      ),
    );
  }
}
