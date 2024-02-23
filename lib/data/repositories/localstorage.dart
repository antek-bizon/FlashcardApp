import 'dart:convert';

import 'package:flashcards/data/models/flashcard.dart';
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

  Future<Map<String, FlashcardGroup>> getFlashcardGroups() async {
    final map = <String, FlashcardGroup>{};
    final groupNames = _pref.getStringList(jsonEntry) ?? [];
    for (final name in groupNames) {
      map[name] = FlashcardGroup(null);
    }

    return map;
  }

  Future<void> addFlashcardGroup(String name) async {
    final keys = _pref.getStringList(jsonEntry) ?? [];
    if (!keys.contains(name) &&
        !(await _pref.setStringList(jsonEntry, [...keys, name]))) {
      throw "Failed to add group locally";
    }
  }

  Future<void> removeGroup(String key) async {
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

  Future<List<FlashcardModel>> getFlashcards(String groupName) async {
    final flashcardsJson = _pref.getString(groupName);

    if (flashcardsJson == null) return [];

    final flashcards = (jsonDecode(flashcardsJson) as List)
        .map(((e) => FlashcardModel(
            question: e["question"], answer: e["answer"], image: e["image"])))
        .toList();

    return flashcards;
  }

  Future<void> updateJson(
      String groupName, List<FlashcardModel> flashcards) async {
    final String json = jsonEncode(flashcards.map((e) => e.toJson()).toList());
    if (!await _pref.setString(groupName, json)) {
      throw "Failed to update group items locally";
    }
  }
}
