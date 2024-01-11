// import 'package:flashcards/model/db.dart';
// import 'package:flashcards/model/theme.dart';
// import 'package:flashcards/utils.dart';
// import 'package:flashcards/widgets/add_dialog.dart';
// import 'package:flashcards/pages/flashcard_group_page.dart';
// import 'package:flashcards/widgets/default_body.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class MyHomePage extends StatefulWidget {
//   final String title = "Flashcards App";
//   const MyHomePage({super.key});

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   final _key = GlobalKey<ScaffoldState>();
//   String? _tooltip = "Logout";
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchGroups();
//   }

//   set loading(bool value) {
//     setState(() {
//       _isLoading = value;
//     });
//   }

//   Future<void> _fetchAllGroups() async {
//     // await Future.delayed(const Duration(seconds: 2));
//     return Provider.of<DatabaseModel>(listen: false, context)
//         .getFlashcardGroups();
//   }

//   Future<void> _fetchGroups() async {
//     loading = true;
//     await _fetchAllGroups();
//     loading = false;
//   }

//   Future<void> _addGroup(String name) async {
//     loading = true;
//     await Provider.of<DatabaseModel>(listen: false, context)
//         .addFlashcardGroup(name);
//     await _fetchAllGroups();
//     loading = false;
//   }

//   void _showAddDialog(BuildContext context) {
//     showDialog<String>(
//         context: context,
//         builder: (BuildContext context) => Consumer<DatabaseModel>(
//             builder: (context, db, _) => AddGroupDialog(
//                 existingGroups: db.flashcardGroups.keys.toSet(),
//                 onAdd: _addGroup)));
//   }

//   Future<void> _removeGroup(BuildContext context, String key) async {
//     loading = true;
//     await Provider.of<DatabaseModel>(listen: false, context)
//         .removeFlashcardGroup(key);
//     if (context.mounted) {
//       await Navigator.maybePop(context);
//     }
//     await _fetchAllGroups();
//     loading = false;
//   }

//   Future<void> _uploadToServer(String name) async {
//     loading = true;
//     final db = Provider.of<DatabaseModel>(listen: false, context);
//     await db.addFlashcardGroup(name);
//     print(await db.uploadGroupItems(name));
//     loading = false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       key: _key,
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           tooltip: _tooltip,
//           onPressed: () {
//             setState(() {
//               _tooltip = null;
//             });
//             Provider.of<DatabaseModel>(context, listen: false).logout();
//           },
//         ),
//         title: Text(
//           widget.title,
//         ),
//       ),
//       bottomNavigationBar: BottomAppBar(
//         shape: const CircularNotchedRectangle(),
//         notchMargin: 10,
//         child: Row(
//           mainAxisSize: MainAxisSize.max,
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             IconButton(
//               onPressed: () {
//                 _key.currentState!.openDrawer();
//               },
//               icon: const Icon(Icons.settings),
//             ),
//             addSpacing(width: 30),
//             IconButton(
//               onPressed: _fetchGroups,
//               icon: const Icon(Icons.replay_outlined),
//             )
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         heroTag: '_MyHomePageState',
//         onPressed: () => _showAddDialog(context),
//         tooltip: 'Add group',
//         shape: const CircleBorder(),
//         child: const Icon(Icons.add),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       extendBody: true,
//       body: DefaultBody(
//         child: Consumer<DatabaseModel>(
//           builder: (context, db, _) {
//             if (_isLoading) {
//               return const Center(
//                 child: CircularProgressIndicator(),
//               );
//             }

//             final items = db.flashcardGroups.entries.toList(growable: false);

//             return SafeArea(
//               child: ListView.builder(
//                   padding: EdgeInsets.symmetric(
//                       horizontal: MediaQuery.of(context).size.width *
//                           MediaQuery.of(context).size.width /
//                           10000),
//                   scrollDirection: Axis.vertical,
//                   itemCount: db.flashcardGroups.length,
//                   itemBuilder: (context, index) {
//                     final item = items[index];

//                     return Card(
//                       child: ListTile(
//                           onTap: (!_isLoading)
//                               ? () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => FlashcardGroupPage(
//                                         groupName: item.key,
//                                         // flashcardGroup: item.value,
//                                         onDelete: () =>
//                                             _removeGroup(context, item.key),
//                                       ),
//                                     ),
//                                   );
//                                 }
//                               : null,
//                           title: Text(item.key),
//                           trailing: (item.value.id != null)
//                               ? const IconButton(
//                                   onPressed: null,
//                                   icon: Icon(Icons.cloud_done_outlined))
//                               : IconButton(
//                                   onPressed: () {
//                                     _uploadToServer(item.key);
//                                   },
//                                   icon: const Icon(Icons.cloud_off_outlined))),
//                     );
//                   }),
//             );
//           },
//         ),
//       ),
//       drawerEnableOpenDragGesture: false,
//       drawer: Drawer(
//         child: ListView(
//           children: [
//             DrawerHeader(
//               decoration: BoxDecoration(
//                 color: theme.colorScheme.primaryContainer,
//               ),
//               child: Text(
//                 'Menu',
//                 style: TextStyle(
//                     color: theme.colorScheme.onPrimaryContainer, fontSize: 30),
//               ),
//             ),
//             Consumer<ThemeModel>(
//               builder: (context, value, child) => ListTile(
//                   title: const Text('Theme Selection'),
//                   subtitle: DropdownButton<ThemeMode>(
//                     alignment: Alignment.center,
//                     borderRadius: BorderRadius.circular(30),
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
//                     value: value.mode,
//                     items: _dropdownMenuItems(),
//                     onChanged: (ThemeMode? mode) {
//                       if (mode == null) return;
//                       value.selectTheme(mode);
//                     },
//                   )),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   List<DropdownMenuItem<ThemeMode>> _dropdownMenuItems() {
//     return ThemeMode.values.map((ThemeMode theme) {
//       return DropdownMenuItem(
//         alignment: Alignment.center,
//         value: theme,
//         child: Text(theme.toString().split('.')[1]),
//       );
//     }).toList();
//   }
// }

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
  String? _tooltip = "Logout";
  late Future<void> _future;

  set setFuture(Future<void> value) {
    setState(() {
      _future = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _future = _fetchAllGroups();
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
            setFuture =
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
              onPressed: () {
                // Trigger the reload by changing the key
                setState(() {
                  _key.currentState!.openEndDrawer();
                  setFuture = _fetchAllGroups();
                });
              },
              icon: const Icon(Icons.replay_outlined),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: '_MyHomePageState',
        onPressed: () => _showAddDialog(context),
        tooltip: 'Add group',
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      extendBody: true,
      body: DefaultBody(
        child: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              // Handle error case
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              final db = Provider.of<DatabaseModel>(context, listen: false);
              final items = db.flashcardGroups.entries.toList(growable: false);

              return SafeArea(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width *
                        MediaQuery.of(context).size.width /
                        10000,
                  ),
                  scrollDirection: Axis.vertical,
                  itemCount: db.flashcardGroups.length,
                  itemBuilder: (context, index) {
                    final item = items[index];

                    return Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FlashcardGroupPage(
                                groupName: item.key,
                                onDelete: () {
                                  setFuture = _removeGroup(context, item.key);
                                },
                              ),
                            ),
                          );
                        },
                        title: Text(item.key),
                        trailing: (item.value.id != null)
                            ? const IconButton(
                                onPressed: null,
                                icon: Icon(Icons.cloud_done_outlined),
                              )
                            : IconButton(
                                onPressed: () {
                                  setFuture = _uploadToServer(item.key);
                                },
                                icon: const Icon(Icons.cloud_off_outlined),
                              ),
                      ),
                    );
                  },
                ),
              );
            }
          },
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
                  color: theme.colorScheme.onPrimaryContainer,
                  fontSize: 30,
                ),
              ),
            ),
            Consumer<ThemeModel>(
              builder: (context, value, child) => ListTile(
                title: const Text('Theme Selection'),
                subtitle: DropdownButton<ThemeMode>(
                  alignment: Alignment.center,
                  borderRadius: BorderRadius.circular(30),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 6,
                  ),
                  value: value.mode,
                  items: _dropdownMenuItems(),
                  onChanged: (ThemeMode? mode) {
                    if (mode == null) return;
                    value.selectTheme(mode);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchAllGroups() async {
    return Provider.of<DatabaseModel>(listen: false, context)
        .getFlashcardGroups();
  }

  Future<void> _addGroup(String name) async {
    await Provider.of<DatabaseModel>(listen: false, context)
        .addFlashcardGroup(name);
    return _fetchAllGroups();
  }

  void _showAddDialog(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => Consumer<DatabaseModel>(
        builder: (context, db, _) => AddGroupDialog(
          existingGroups: db.flashcardGroups.keys.toSet(),
          onAdd: (String name) {
            setFuture = _addGroup(name);
          },
        ),
      ),
    );
  }

  Future<void> _removeGroup(BuildContext context, String key) async {
    await Provider.of<DatabaseModel>(listen: false, context)
        .removeFlashcardGroup(key);
    if (context.mounted) {
      await Navigator.maybePop(context);
    }
    return _fetchAllGroups();
  }

  Future<void> _uploadToServer(String name) async {
    final db = Provider.of<DatabaseModel>(listen: false, context);
    await db.addFlashcardGroup(name);
    print(await db.uploadGroupItems(name));
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
