import 'dart:async';
import 'dart:convert';

import 'package:flashcards/flashcards/flashcard.dart';
import 'package:flashcards/model/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseModel extends ChangeNotifier {
  final _pb = PocketBase("https://antek-bizon.xinit.se/pb/");
  final _pref = SharedPreferences.getInstance();
  bool _healthy = true;
  bool _lastHealthy = true;
  Timer? _healthCheckTimer;
  final jsonEntry = "groupNames";
  var _flashcardGroups = <String, FlashcardGroupOptions>{};
  List<Flashcard> _flashcards = [];
  Map<String, FlashcardGroupOptions> get flashcardGroups => _flashcardGroups;
  List<Flashcard> get flashcards => _flashcards;
  bool _offlineMode = false;

  bool get isAuth {
    return _pb.authStore.isValid && _pb.authStore.token.isNotEmpty;
  }

  Future<bool> get isOnline async {
    if (_offlineMode) {
      return false;
    }
    await _doHealthCheck();
    return _healthy;
  }

  bool get isOfflineMode => _offlineMode;

  Future<void> login(String email, String password, bool save) async {
    try {
      _ensureKeepAlive();
      await _pb.collection("users").authWithPassword(email, password);
      _healthy = true;
      _offlineMode = false;
      if (save) {
        final pref = await _pref;
        pref.setStringList("autologin", [email, password]);
      }
      notifyListeners();
    } on ClientException catch (err) {
      throw ExceptionMessage(err.response["message"].toString());
    }
  }

  Future<void> logout() async {
    try {
      _healthCheckTimer?.cancel();
      _healthCheckTimer = null;
      _pb.authStore.clear();
      _offlineMode = false;
      final prefs = await SharedPreferences.getInstance();
      prefs.remove("autologin");
      notifyListeners();
    } on ClientException catch (err) {
      throw ExceptionMessage(err.response["message"].toString());
    }
  }

  void openInOfflineMode() {
    _offlineMode = true;
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
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
    } on Exception {
      return false;
    }
  }

  Future<void> _doHealthCheck() async {
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

  Future<void> _ensureKeepAlive() async {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _doHealthCheck();
    });
  }

  // ----------------------------- Getting groups ----------------------------------

  Future<void> getFlashcardGroups() async {
    final online = await isOnline;
    final futures = [
      _getFlashcardGroupsLocal(),
      if (online) _getFlashcardGroupsServer()
    ];
    clearFlashcards();
    final results = await Future.wait(futures);

    _flashcardGroups = {...results[0], if (online) ...results[1]};
  }

  Future<Map<String, FlashcardGroupOptions>> _getFlashcardGroupsServer() async {
    try {
      final dbResponse = await _pb
          .collection('flashcard_groups')
          .getFullList(fields: "id,name");
      final map = <String, FlashcardGroupOptions>{};
      for (final field in dbResponse) {
        final id = field.id;
        final flashcardGroupName = field.getStringValue("name");
        map[flashcardGroupName] = FlashcardGroupOptions(id: id);
      }
      return map;
    } on ClientException catch (err) {
      throw ExceptionMessage(err.response["message"].toString());
    }
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

  // ----------------------------- Adding group ----------------------------------

  Future<void> addFlashcardGroup(String name) async {
    final futures = [
      if (await isOnline) _addFlashcardGroupServer(name),
      _addFlashcardGroupLocal(name)
    ];
    await Future.wait(futures);
  }

  Future<void> _addFlashcardGroupServer(String name) async {
    try {
      await _pb.collection("flashcard_groups").create(body: {"name": name});
    } on ClientException catch (err) {
      throw ExceptionMessage(err.response["message"].toString());
    }
  }

  Future<void> _addFlashcardGroupLocal(String name) async {
    final pref = await _pref;
    final keys = pref.getStringList(jsonEntry) ?? [];
    if (!keys.contains(name) &&
        !(await pref.setStringList(jsonEntry, [...keys, name]))) {
      throw ExceptionMessage("Failed to add group locally");
    }
  }

  // ----------------------------- Removing group ----------------------------------

  Future<void> removeFlashcardGroup(String key) async {
    final id = _flashcardGroups[key]?.id;
    final futures = [
      if (await isOnline) _removeFlashcardGroupServer(id),
      _removeGroupLocal(key)
    ];

    await Future.wait(futures);
  }

  Future<void> _removeFlashcardGroupServer(String? id) async {
    try {
      if (id == null) {
        throw ExceptionMessage(
            "Failed to remove group from server. Id was a null");
      }
      await _pb.collection("flashcard_groups").delete(id);
    } on ClientException catch (err) {
      throw ExceptionMessage(err.response["message"].toString());
    }
  }

  Future<void> _removeGroupLocal(String key) async {
    final pref = await _pref;
    final keys = pref.getStringList(jsonEntry) ?? [];
    if (!keys.remove(key)) {
      throw ExceptionMessage("Removing local group key failed");
    }

    final results = await Future.wait([
      pref.setStringList(jsonEntry, [...keys]),
      pref.remove(key)
    ]);

    for (final result in results) {
      if (!result) {
        throw ExceptionMessage("Removing group from local storage failed");
      }
    }
  }

  void clearFlashcards() {
    _flashcards.clear();
  }

  // ----------------------------- Getting flashcards ----------------------------------

  Future<void> getFlashcards(String groupName) async {
    final online = await isOnline;
    final futures = [
      if (await isOnline) _getFlashcardsServer(groupName),
      _getFlashcardsLocal(groupName)
    ];
    final result = await Future.wait(futures);
    _flashcards = [
      ...{if (online) ...result[1], ...result[0]}
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
    try {
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
    } on ClientException catch (err) {
      throw ExceptionMessage(err.response["message"].toString());
    }
  }

  // ----------------------------- Adding flashcard ----------------------------------

  Future<void> addFlashcard(String groupName, Flashcard item) async {
    _flashcards.add(item);
    final futures = [
      if (await isOnline) _addFlashcardServer(groupName, item),
      _updateJson(groupName)
    ];
    Future.wait(futures).whenComplete(notifyListeners);
  }

  Future<void> _addFlashcardServer(String groupName, Flashcard item) async {
    try {
      final groupId = _flashcardGroups[groupName]?.id;
      if (groupId == null) {
        throw ExceptionMessage("Cannot add flashcard. Group Id is null");
      }
      final body = {
        "question": item.question,
        "answer": item.answer,
        "flashcard_group": groupId
      };
      await _pb.collection("flashcards").create(body: body);
    } on ClientException catch (err) {
      throw ExceptionMessage(err.response["message"].toString());
    }
  }

  Future<void> _updateJson(String groupName) async {
    final pref = await _pref;
    final String json = jsonEncode(_flashcards.map((e) => e.toJson()).toList());
    if (!await pref.setString(groupName, json)) {
      throw ExceptionMessage("Failed to update group items locally");
    }
  }

  // ----------------------------- Removing flashcard ----------------------------------

  Future<void> removeFlashcard(String groupName, int index) async {
    final item = _flashcards.removeAt(index);
    final futures = [
      if (await isOnline) _removeFlashcardServer(item),
      _updateJson(groupName)
    ];
    Future.wait(futures).whenComplete(notifyListeners);
  }

  Future<void> _removeFlashcardServer(Flashcard item) async {
    try {
      final id = item.id;
      if (id == null) {
        throw ExceptionMessage("Cannot remove flashcard. Id is null");
      }

      await _pb.collection("flashcards").delete(id);
    } on ClientException catch (err) {
      throw ExceptionMessage(err.response["message"].toString());
    }
  }

  // ----------------------------- Updating flashcard ----------------------------------

  Future<void> updateFlashcard(String groupName, int index) async {
    final item = _flashcards.elementAt(index);
    final futures = [
      if (await isOnline) _updateFlashcardServer(item),
      _updateJson(groupName)
    ];
    Future.wait(futures).whenComplete(notifyListeners);
  }

  Future<void> _updateFlashcardServer(Flashcard item) async {
    try {
      final id = item.id;
      if (id == null) {
        throw ExceptionMessage("Cannot update flashcard. Id is null");
      }

      final body = {"question": item.question, "answer": item.answer};

      await _pb.collection("flashcards").update(id, body: body);
    } on ClientException catch (err) {
      throw ExceptionMessage(err.response["message"].toString());
    }
  }

  // ----------------------------- Uploding group flashcards ----------------------------------

  Future<void> uploadGroupItems(String groupName) async {
    final flashcards = await _getFlashcardsLocal(groupName);
    final requests =
        flashcards.map((e) => _addFlashcardServer(groupName, e)).toList();
    Future.wait(requests);
  }
}
