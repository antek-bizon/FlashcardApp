import 'dart:async';
import 'dart:convert';

import 'package:flashcards/flashcards/flashcard.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseModel extends ChangeNotifier {
  final _pb = PocketBase("http://127.0.0.1:8090");
  final _pref = SharedPreferences.getInstance();
  bool _healthy = true;
  bool _lastHealthy = true;
  Timer? _healthCheckTimer;
  final jsonEntry = "groupNames";
  var _flashcardGroups = <String, FlashcardGroupOptions>{};
  List<Flashcard> _flashcards = [];
  Map<String, FlashcardGroupOptions> get flashcardGroups => _flashcardGroups;
  List<Flashcard> get flashcards => _flashcards;

  bool get isAuth {
    return _pb.authStore.isValid && _pb.authStore.token.isNotEmpty;
  }

  Future<void> login(String email, String password, bool save) async {
    ensureKeepAlive();
    await _pb.collection("users").authWithPassword(email, password);
    _healthy = true;
    if (save) {
      final pref = await _pref;
      pref.setStringList("autologin", [email, password]);
    }
    notifyListeners();
  }

  Future<void> logout() async {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;
    _pb.authStore.clear();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("autologin");
    notifyListeners();
  }

  Future<bool> autoLogin() async {
    if (_pb.authStore.isValid) {
      return true;
    }

    final pref = await _pref;
    final data = pref.getStringList("autologin");
    if (data == null || data.length != 2) {
      return false;
    }

    try {
      await login(data[0], data[1], false);
      return true;
    } on ClientException {
      return false;
    }
  }

  Future<void> getFlashcardGroups() async {
    final storageFuture = _getFlashcardGroupsLocal();
    final dbFuture = _getFlashcardGroupsServer();
    clearFlashcards();
    final results = await Future.wait([storageFuture, dbFuture]);

    _flashcardGroups = {...results[0], ...results[1]};
    notifyListeners();
  }

  Future<Map<String, FlashcardGroupOptions>> _getFlashcardGroupsServer() async {
    final dbResponse =
        await _pb.collection('flashcard_groups').getFullList(fields: "id,name");
    final map = <String, FlashcardGroupOptions>{};
    for (final field in dbResponse) {
      final id = field.id;
      final flashcardGroupName = field.getStringValue("name");
      map[flashcardGroupName] = FlashcardGroupOptions(id: id);
    }
    return map;
  }

  Future<Map<String, FlashcardGroupOptions>> _getFlashcardGroupsLocal() async {
    final pref = await _pref;
    final map = <String, FlashcardGroupOptions>{};
    final groupNames = pref.getStringList(jsonEntry) ?? [];
    for (final name in groupNames) {
      map[name] = FlashcardGroupOptions();
    }

    return map;
  }

  Future<(bool, bool)> addFlashcardGroup(String name) async {
    final server = _addFlashcardGroupServer(name);
    final local = _addFlashcardGroupLocal(name);
    final results = await Future.wait([server, local]);
    // notifyListeners();
    return (results[0], results[1]);
  }

  Future<bool> _addFlashcardGroupServer(String name) async {
    try {
      // final record =
      await _pb.collection("flashcard_groups").create(body: {"name": name});
      return true;
    } on ClientException {
      return false;
    }
  }

  Future<bool> _addFlashcardGroupLocal(String name) async {
    final pref = await _pref;
    final keys = pref.getStringList(jsonEntry) ?? [];
    if (keys.contains(name)) {
      return Future.value(true);
    }
    return pref.setStringList(jsonEntry, [...keys, name]);
  }

  Future<(bool, bool)> removeFlashcardGroup(String key) async {
    final id = _flashcardGroups[key]?.id;
    final Future<bool> server =
        (id != null) ? _removeFlashcardGroupServer(id) : Future.value(false);
    final local = _removeGroupLocal(key);

    final results = await Future.wait([server, local]);
    // notifyListeners();
    return (results[0], results[1]);
  }

  Future<bool> _removeFlashcardGroupServer(String id) async {
    try {
      await _pb.collection("flashcard_groups").delete(id);
      return true;
    } on ClientException {
      return false;
    }
  }

  Future<bool> _removeGroupLocal(String key) async {
    final pref = await _pref;
    final keys = pref.getStringList(jsonEntry) ?? [];
    final result = keys.remove(key);
    await Future.wait([
      pref.setStringList(jsonEntry, [...keys]),
      pref.remove(key)
    ]);
    return result;
  }

  void clearFlashcards() {
    _flashcards.clear();
  }

  Future<void> getFlashcards(String groupName) async {
    final local = _getFlashcardsLocal(groupName);
    final server = _getFlashcardsServer(groupName);
    final result = await Future.wait([local, server]);
    _flashcards = [
      ...{...result[1], ...result[0]}
    ];
    notifyListeners();
  }

  Future<List<Flashcard>> _getFlashcardsLocal(String groupName) async {
    final pref = await _pref;
    final flashcardsJson = pref.getString(groupName);

    if (flashcardsJson == null) return [];

    final flashcards = (jsonDecode(flashcardsJson) as List)
        .map(((e) => Flashcard(
            question: e["question"], answer: e["answer"], image: e["image"])))
        .toList();

    return flashcards;
  }

  Future<List<Flashcard>> _getFlashcardsServer(String groupName) async {
    final groupId = _flashcardGroups[groupName]?.id;
    if (groupId == null) {
      return [];
    }

    final dbResponse = await _pb
        .collection('flashcards')
        .getFullList(filter: "flashcard_group.id = '$groupId'");

    return dbResponse.map<Flashcard>((e) {
      final id = e.id;
      final question = e.getStringValue("question");
      final answer = e.getStringValue("answer");

      return Flashcard(question: question, answer: answer, id: id);
    }).toList();
  }

  Future<bool> _updateJson(String groupName) async {
    final pref = await _pref;
    final String json = jsonEncode(_flashcards.map((e) => e.toJson()).toList());
    return pref.setString(groupName, json);
  }

  Future<(bool, bool)> addFlashcard(String groupName, Flashcard item) async {
    _flashcards.add(item);
    final local = _updateJson(groupName);
    final server = _addFlashcardServer(groupName, item);
    final results = await Future.wait([local, server]);
    notifyListeners();
    return (results[0], results[1]);
  }

  Future<bool> _addFlashcardServer(String groupName, Flashcard item) async {
    final groupId = _flashcardGroups[groupName]?.id;
    if (groupId == null) {
      return false;
    }
    final body = {
      "question": item.question,
      "answer": item.answer,
      "flashcard_group": groupId
    };
    try {
      await _pb.collection("flashcards").create(body: body);
      return true;
    } on ClientException {
      return false;
    }
  }

  Future<(bool, bool)> removeFlashcard(String groupName, int index) async {
    final item = _flashcards.removeAt(index);
    final local = _updateJson(groupName);
    final server = _removeFlashcardServer(item);
    final results = await Future.wait([local, server]);
    notifyListeners();
    return (results[0], results[1]);
  }

  Future<bool> _removeFlashcardServer(Flashcard item) async {
    final id = item.id;
    if (id == null) {
      return false;
    }

    try {
      _pb.collection("flashcards").delete(id);
      return true;
    } on ClientException {
      return false;
    }
  }

  Future<(bool, bool)> updateFlashcard(String groupName, int index) async {
    final item = _flashcards.elementAt(index);
    final local = _updateJson(groupName);
    final server = _updateFlashcardServer(item);
    final results = await Future.wait([local, server]);
    notifyListeners();
    return (results[0], results[1]);
  }

  Future<bool> _updateFlashcardServer(Flashcard item) async {
    final id = item.id;
    if (id == null) {
      return false;
    }

    final body = {"question": item.question, "answer": item.answer};

    try {
      await _pb.collection("flashcards").update(id, body: body);
      return true;
    } on ClientException {
      return false;
    }
  }

  Future<int> uploadGroupItems(String groupName) async {
    final flashcards = await _getFlashcardsLocal(groupName);
    print(flashcards.length);
    final requests =
        flashcards.map((e) => _addFlashcardServer(groupName, e)).toList();
    final results = await Future.wait(requests);
    var counter = 0;
    for (var e in results) {
      if (e == false) {
        counter += 1;
      }
    }
    return counter;
  }

  Future<void> doHealthCheck() async {
    _pb.health.check().then((value) {
      _healthy = true;
    }).onError((error, stackTrace) {
      _healthy = false;
    }).whenComplete(() {
      if (_healthy != _lastHealthy) {
        notifyListeners();
      }
      _lastHealthy = _healthy;
    });
  }

  Future<void> ensureKeepAlive() async {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      doHealthCheck();
    });
  }
}
