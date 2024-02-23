import 'package:flashcards/cubits/auth.dart';
import 'package:flashcards/cubits/theme.dart';
import 'package:flashcards/presentation/group_page.dart';
import 'package:flashcards/presentation/home_page.dart';
import 'package:flashcards/presentation/login_page.dart';
import 'package:flashcards/data/repositories/theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class App extends StatelessWidget {
  final ThemeRepository themeRepository;

  const App({super.key, required this.themeRepository});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: themeRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => ThemeCubit(context.read<ThemeRepository>())
                ..getCurrentTheme())
          // ChangeNotifierProvider<ThemeModel>(create: (_) => ThemeModel()),
          // ChangeNotifierProvider<DatabaseModel>(create: (_) => DatabaseModel())
        ],
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    final lightScheme = ColorScheme.fromSeed(seedColor: Colors.greenAccent);
    final darkScheme = ColorScheme.fromSeed(
        seedColor: Colors.pink, brightness: Brightness.dark);

    return BlocBuilder<ThemeCubit, ThemeState>(builder: (context, state) {
      return MaterialApp(
          title: 'Flashcards',
          theme: ThemeData(
              colorScheme: lightScheme,
              useMaterial3: true,
              textTheme: GoogleFonts.mulishTextTheme()),
          darkTheme: ThemeData(
              colorScheme: darkScheme,
              useMaterial3: true,
              textTheme: GoogleFonts.mulishTextTheme(const TextTheme(
                  titleMedium: TextStyle(color: Colors.white)))),
          themeMode: state.mode,
          routes: {
            LoginPage.route: (_) => const LoginPage(),
            HomePage.route: (_) => const HomePage(),
            // '/group': (_) => const GroupPage(),
          },
          home: BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
            return const LoginPage();
          }));
    });
  }
}
