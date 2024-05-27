import 'package:flashcards/cubits/auth.dart';
import 'package:flashcards/cubits/groups.dart';
import 'package:flashcards/cubits/theme.dart';
import 'package:flashcards/data/models/quiz_group.dart';
import 'package:flashcards/presentation/widgets/dialogs/add_group.dart';
import 'package:flashcards/utils.dart';
import 'package:flashcards/presentation/group_page.dart';
import 'package:flashcards/presentation/widgets/default_body.dart';
import 'package:flashcards/presentation/widgets/my_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  static const String title = "Flashcards App";
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<GroupCubit>().fetchGroups(authState(context));
  }

  @override
  Widget build(BuildContext context) {
    return HomePageBody(
        onPop: () {
          context.read<AuthCubit>().logout();
        },
        bottomBarFuntions: [
          () => {},
          () => context.read<GroupCubit>().fetchGroups(authState(context))
        ],
        onFABPress: () => showAddDialog(context),
        themeSelector: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, state) {
            if (state.message != null) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(quickSnack(state.message!));
            }
            return ListTile(
              title: const Text('Theme Selection'),
              subtitle: DropdownButton<ThemeMode>(
                alignment: Alignment.center,
                borderRadius: BorderRadius.circular(30),
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 6,
                ),
                value: state.mode,
                items: _dropdownMenuItems(),
                onChanged: (ThemeMode? mode) {
                  if (mode == null) return;
                  context.read<ThemeCubit>().setTheme(mode);
                },
              ),
            );
          },
        ),
        child: BlocConsumer<GroupCubit, GroupState>(
          builder: (context, state) {
            if (state is SuccessGroupState) {
              final groups = state.groups.values.toList();
              return GroupList(groups: groups);
            } else if (state is ErrorGroupState) {
              return const Center(
                  child: Text("Error has occured. Please try again."));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
          listener: (context, state) {
            if (state is ErrorGroupState) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(quickSnack(state.message));
            }
          },
        ));
  }

  void showAddDialog(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => BlocBuilder<GroupCubit, GroupState>(
        builder: (context, state) {
          if (state is SuccessGroupState) {
            final group = state.groups;
            return AddGroupDialog(
                existingGroups: group.keys.toSet(),
                onAdd: (String name) {
                  context.read<GroupCubit>().addGroup(authState(context), name);
                });
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  List<DropdownMenuItem<ThemeMode>> _dropdownMenuItems() {
    return ThemeMode.values.map((ThemeMode theme) {
      return DropdownMenuItem(
        alignment: Alignment.center,
        value: theme,
        child: Text(theme.toString().split('.')[1]),
      );
    }).toList();
  }
}

class HomePageBody extends StatefulWidget {
  final VoidCallback onPop;
  final VoidCallback onFABPress;
  final List<VoidCallback> bottomBarFuntions;
  final Widget child;
  final Widget themeSelector;

  const HomePageBody(
      {super.key,
      required this.onPop,
      required this.bottomBarFuntions,
      required this.onFABPress,
      required this.child,
      required this.themeSelector});
  @override
  State<HomePageBody> createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  final _key = GlobalKey<ScaffoldState>();
  String? _tooltip = "Logout";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _key,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: _tooltip,
          onPressed: () {
            setState(() {
              _tooltip = null;
            });
            widget.onPop();
          },
        ),
        title: const Text(HomePage.title),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                _key.currentState?.openDrawer();
                widget.bottomBarFuntions[0]();
              },
              icon: const Icon(Icons.settings),
            ),
            addSpacing(width: 30),
            IconButton(
              onPressed: () {
                _key.currentState?.closeDrawer();
                widget.bottomBarFuntions[1]();
              },
              icon: const Icon(Icons.replay_outlined),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: '_MyHomePageState',
        onPressed: widget.onFABPress,
        tooltip: 'Add group',
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      extendBody: true,
      body: DefaultBody(child: widget.child),
      drawerEnableOpenDragGesture: false,
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontSize: 30,
                ),
              ),
            ),
            widget.themeSelector
          ],
        ),
      ),
    );
  }
}

class GroupList extends StatelessWidget {
  final List<QuizGroup> groups;

  const GroupList({super.key, required this.groups});

  IconButton _cloudIcon(BuildContext context, QuizGroup group) {
    return (group.id != null)
        ? const IconButton(
            onPressed: null,
            icon: Icon(Icons.cloud_done_outlined),
          )
        : IconButton(
            onPressed: () => context
                .read<GroupCubit>()
                .uploadGroupItems(authState(context), group.name),
            icon: const Icon(Icons.cloud_off_outlined),
          );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width *
              MediaQuery.of(context).size.width /
              10000,
        ),
        scrollDirection: Axis.vertical,
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];

          return Card(
            child: ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupPage(group: group),
                    ));
              },
              title: Text(group.name),
              trailing: (BlocProvider.of<AuthCubit>(context).state
                      is SuccessAuthState)
                  ? _cloudIcon(context, group)
                  : null,
            ),
          );
        },
      ),
    );
  }
}
