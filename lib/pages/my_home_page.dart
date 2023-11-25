import 'dart:convert';

import 'package:flashcards/flashcards/flashcard.dart';
import 'package:flashcards/model/db.dart';
import 'package:flashcards/model/theme.dart';
import 'package:flashcards/utils.dart';
import 'package:flashcards/widgets/add_dialog.dart';
import 'package:flashcards/pages/flashcard_group_page.dart';
import 'package:flashcards/widgets/default_body.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  final String title = "Flashcards App";
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _key = GlobalKey<ScaffoldState>();
  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  String? _tooltip = "Logout";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  set loading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  Future<Map<String, FlashcardGroupOptions>> _fetchAllGroups() async {
    // await Future.delayed(const Duration(seconds: 2));
    return Provider.of<DatabaseModel>(listen: false, context)
        .getFlashcardGroups();
  }

  Future<void> _fetchGroups() async {
    loading = true;
    await _fetchAllGroups();
    loading = false;
  }

  Future<void> _addGroup(String name) async {
    loading = true;
    await Provider.of<DatabaseModel>(listen: false, context)
        .addFlashcardGroup(name);
    await _fetchAllGroups();
    loading = false;
  }

  void _showAddDialog(BuildContext context) {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => Consumer<DatabaseModel>(
            builder: (context, db, _) => AddGroupDialog(
                existingGroups: db.flashcardGroups.keys.toSet(),
                onAdd: _addGroup)));
  }

  Future<void> _removeGroup(BuildContext context, String key) async {
    loading = true;
    await Provider.of<DatabaseModel>(listen: false, context)
        .removeFlashcardGroup(key);
    await _fetchAllGroups();
    loading = false;
  }

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
            Provider.of<DatabaseModel>(context, listen: false).logout();
          },
        ),
        title: Text(
          widget.title,
        ),
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
                _key.currentState!.openDrawer();
              },
              icon: const Icon(Icons.settings),
            ),
            addSpacing(width: 30),
            IconButton(
              onPressed: () => _refreshKey.currentState?.show(),
              icon: const Icon(Icons.replay_outlined),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => _showAddDialog(context),
        tooltip: 'Add group',
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      extendBody: true,
      body: DefaultBody(
        child: RefreshIndicator(
          key: _refreshKey,
          onRefresh: _fetchGroups,
          backgroundColor: theme.colorScheme.primary,
          color: theme.colorScheme.onPrimary,
          strokeWidth: 4.0,
          child: Consumer<DatabaseModel>(builder: (context, db, _) {
            final items = db.flashcardGroups.entries.toList(growable: false);

            return SafeArea(
              child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width *
                          MediaQuery.of(context).size.width /
                          10000),
                  scrollDirection: Axis.vertical,
                  itemCount: db.flashcardGroups.length,
                  itemBuilder: (context, index) {
                    final item = items[index];

                    return Card(
                      child: ListTile(
                        onTap: (!_isLoading)
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FlashcardGroupPage(
                                      groupName: item.key,
                                      // flashcardGroup: item.value,
                                      onDelete: () =>
                                          _removeGroup(context, item.key),
                                    ),
                                  ),
                                );
                              }
                            : null,
                        title: Text(item.key),
                      ),
                    );
                  }),
            );
          }),
        ),
      ),
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
                    color: theme.colorScheme.onPrimaryContainer, fontSize: 30),
              ),
            ),
            Consumer<ThemeModel>(
              builder: (context, value, child) => ListTile(
                  title: const Text('Theme Selection'),
                  subtitle: DropdownButton<ThemeMode>(
                    alignment: Alignment.center,
                    borderRadius: BorderRadius.circular(30),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                    value: value.mode,
                    items: _dropdownMenuItems(),
                    onChanged: (ThemeMode? mode) {
                      if (mode == null) return;
                      value.selectTheme(mode);
                    },
                  )),
            ),
          ],
        ),
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
