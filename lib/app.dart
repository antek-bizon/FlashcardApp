import 'package:flashcards/cubits/auth.dart';
import 'package:flashcards/cubits/flashcards.dart';
import 'package:flashcards/cubits/groups.dart';
import 'package:flashcards/cubits/theme.dart';
import 'package:flashcards/data/models/group_page_arguments.dart';
import 'package:flashcards/data/repositories/database.dart';
import 'package:flashcards/data/repositories/localstorage.dart';
import 'package:flashcards/presentation/group_page.dart';
import 'package:flashcards/presentation/home_page.dart';
import 'package:flashcards/presentation/login_page.dart';
import 'package:flashcards/data/repositories/theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class App extends StatelessWidget {
  final ThemeRepository themeRepository;
  final DatabaseRepository databaseRepository;
  final LocalStorageRepository localStorageRepository;

  const App(
      {super.key,
      required this.themeRepository,
      required this.databaseRepository,
      required this.localStorageRepository});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) =>
                ThemeCubit(themeRepository)..getCurrentTheme()),
        BlocProvider(
            create: (context) => AuthCubit(databaseRepository)..autoLogin()),
        BlocProvider(
            create: (context) => GroupCubit(
                databaseRepository: databaseRepository,
                localStorageRepository: localStorageRepository)),
        BlocProvider(
            create: (context) => CardCubit(
                databaseRepository: databaseRepository,
                localStorageRepository: localStorageRepository)),
      ],
      child: const AppView(),
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

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

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
            textTheme: GoogleFonts.mulishTextTheme(
                const TextTheme(titleMedium: TextStyle(color: Colors.white)))),
        themeMode: state.mode,
        routes: {
          LoginPage.route: (_) => const LoginPage(),
          HomePage.route: (_) => const HomePage(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == GroupPage.route) {
            final args = settings.arguments as GroupPageArguments;
            return MaterialPageRoute(
                settings: RouteSettings(name: "/${args.groupName}"),
                builder: (context) => GroupPage(
                      groupName: args.groupName,
                      groupId: args.groupId,
                    ));
          }
          return null;
        },
        home: const LoginPage(),
      );
    });
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
