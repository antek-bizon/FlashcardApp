import 'dart:convert';

import 'package:flashcards/flashcards/flashcard.dart';
import 'package:flashcards/utils.dart';
import 'package:flashcards/widgets/add_dialog.dart';
import 'package:flashcards/pages/flashcard_group_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  final String title = "Flashcards App";

  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String jsonEntry = "groupNames";
  final _key = GlobalKey<ScaffoldState>();
  late Future<Map<String, List<Flashcard>>> _data;
  final _prefData = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    _data = _prefData.then(_getFlashcardGroups);
  }

  Map<String, List<Flashcard>> _getFlashcardGroups(SharedPreferences pref) {
    final map = <String, List<Flashcard>>{};
    final groupNames = pref.getStringList(jsonEntry) ?? [];

    for (var groupName in groupNames) {
      final flashcardsJson = pref.getString(groupName);
      if (flashcardsJson != null) {
        final flashcards = (jsonDecode(flashcardsJson) as List)
            .map(((e) => Flashcard(
                question: e["question"],
                answer: e["answer"],
                image: e["image"])))
            .toList();

        map[groupName] = flashcards;
      } else {
        map[groupName] = [];
      }
    }

    return map;
  }

  Future<void> _addGroup(String key) async {
    final prefs = await _prefData;
    final data = await _data;
    setState(() {
      final newKeys = [...data.keys, key];
      prefs.setStringList(jsonEntry, newKeys).then((success) {
        data[key] = List.empty(growable: true);
      });
    });
  }

  void _showAddDialog(BuildContext context) {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => FutureBuilder(
              future: _data,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.active:
                  case ConnectionState.done:
                    return AddGroupDialog(
                        existingGroups:
                            snapshot.data?.keys.toSet() ?? <String>{},
                        onAdd: _addGroup);
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const CircularProgressIndicator();
                }
              },
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        // backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          widget.title,
          // style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
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
              onPressed: () {},
              icon: const Icon(Icons.settings),
            ),
            addSpacing(width: 30),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.disc_full_rounded),
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
      body: Center(
        child: FutureBuilder(
          future: _data,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.active:
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else {
                  final data = snapshot.data;
                  if (data == null) return ListView();

                  return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      scrollDirection: Axis.vertical,
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final item = data.entries.elementAt(index);

                        return Card(
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FlashcardGroupPage(
                                    groupName: item.key,
                                    // flashcardGroup: item.value,
                                    onDelete: () {
                                      setState(() {
                                        Navigator.pop(context);
                                        data.remove(item.key);
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                            title: Text(item.key),
                          ),
                        );
                      });
                }
              case ConnectionState.none:
              case ConnectionState.waiting:
                return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
