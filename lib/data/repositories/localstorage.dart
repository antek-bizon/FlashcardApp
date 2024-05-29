import 'dart:convert';

import 'package:flashcards/data/models/quiz_group.dart';
import 'package:flashcards/data/models/quiz_item.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageRepository {
  final SharedPreferences _pref;
  static const String jsonEntry = "groupNames";

  LocalStorageRepository(SharedPreferences pref) : _pref = pref;

  Future<void> autoLogin(String email, String password) async {
    final result = await _pref.setStringList("autologin", [email, password]);
    if (!result) {
      throw "Setting auto login option failed";
    }
  }

  Future<void> logout() async {
    final result = await _pref.remove("autologin");
    if (!result) {
      throw "Removing auto login option failed";
    }
  }

  Future<Map<String, QuizGroup>> getQuizGroups() async {
    final map = <String, QuizGroup>{};
    final groupNames = _pref.getStringList(jsonEntry) ?? [];
    for (final name in groupNames) {
      map[name] = QuizGroup(name: name);
    }

    return map;
  }

  Future<void> addQuizGroup(String name) async {
    final keys = _pref.getStringList(jsonEntry) ?? [];
    if (!keys.contains(name) &&
        !(await _pref.setStringList(jsonEntry, [...keys, name]))) {
      throw "Failed to add group locally";
    }
  }

  Future<void> removeQuizGroup(String key) async {
    final keys = _pref.getStringList(jsonEntry) ?? [];
    if (!keys.remove(key)) {
      throw "Removing local group key failed";
    }

    final results = await Future.wait([
      _pref.setStringList(jsonEntry, [...keys]),
      _pref.remove(key)
    ]);

    for (final result in results) {
      if (!result) {
        throw "Removing group from local storage failed";
      }
    }
  }

  Future<(List<QuizItem>, String?)> getQuizItem(String groupName) async {
    final flashcardsJson = _pref.getString(groupName);

    if (flashcardsJson == null) return (<QuizItem>[], null);

    final List<QuizItem> flashcards = [];
    int numOfErrors = 0;

    for (final Map<String, dynamic> e in jsonDecode(flashcardsJson) as List) {
      try {
        if (!e.containsKey("type") || !e.containsKey("data")) {
          continue;
        }

        final typeIndex = e["type"] as int;
        final type = QuizItemType.values[typeIndex];
        final json = e["data"] as Map<String, dynamic>;
        final imageUri = e["image"];

        flashcards.add(QuizItem.fromJson(
          type: type,
          json: json,
          imageUri: imageUri,
        ));
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
        numOfErrors += 1;
      }
    }

    final message = (numOfErrors > 0)
        ? "The number of elemenets that failed: $numOfErrors"
        : null;

    return (flashcards, message);
  }

  Future<void> updateJson(String groupName, List<QuizItem> flashcards) async {
    final String json = jsonEncode(flashcards.map((e) => e.toJson()).toList());
    if (!await _pref.setString(groupName, json)) {
      throw "Failed to update group items locally";
    }
  }
}
