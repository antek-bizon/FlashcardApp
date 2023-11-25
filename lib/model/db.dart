import 'dart:async';

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

  Map<String, FlashcardGroupOptions> get flashcardGroups => _flashcardGroups;

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

  Future<Map<String, FlashcardGroupOptions>> getFlashcardGroups() async {
    final storageFuture = _getFlashcardGroupsLocal();
    final dbFuture = _getFlashcardGroupsServer();
    final results = await Future.wait([storageFuture, dbFuture]);

    _flashcardGroups = {...results[0], ...results[1]};
    return _flashcardGroups;
  }

  Future<Map<String, FlashcardGroupOptions>> _getFlashcardGroupsServer() async {
    final dbResponse =
        await _pb.collection('flashcard_groups').getList(fields: "id,name");
    final map = <String, FlashcardGroupOptions>{};
    for (final field in dbResponse.items) {
      final id = field.id;
      final flashcardGroupName = field.getStringValue("name");
      map[flashcardGroupName] =
          FlashcardGroupOptions(type: StorageType.server, id: id);
    }
    return map;
  }

  Future<Map<String, FlashcardGroupOptions>> _getFlashcardGroupsLocal() async {
    final pref = await _pref;
    final map = <String, FlashcardGroupOptions>{};
    final groupNames = pref.getStringList(jsonEntry) ?? [];
    for (final name in groupNames) {
      map[name] = FlashcardGroupOptions(type: StorageType.client);
    }

    return map;
  }

  Future<(bool, bool)> addFlashcardGroup(String name) async {
    final server = _addFlashcardGroupServer(name);
    final local = _addFlashcardGroupLocal(name);
    final results = await Future.wait([server, local]);
    notifyListeners();
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
    return pref.setStringList(jsonEntry, [...keys, name]);
  }

  Future<(bool, bool)> removeFlashcardGroup(String key) async {
    final id = _flashcardGroups[key]?.id;
    final Future<bool> server =
        (id != null) ? _removeFlashcardGroupServer(id) : Future.value(false);
    final local = _removeGroupLocal(key);

    final results = await Future.wait([server, local]);
    notifyListeners();
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
