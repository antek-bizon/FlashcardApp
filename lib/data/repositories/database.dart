import 'dart:async';

import 'package:flashcards/data/models/quiz_group.dart';
import 'package:flashcards/data/models/quiz_item.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;

class DatabaseRepository {
  final PocketBase _pb;

  DatabaseRepository(PocketBase pb) : _pb = pb;

  Future<void> login(String email, String password) async {
    try {
      await _pb.collection("users").authWithPassword(email, password);
    } on ClientException catch (err) {
      throw err.response["message"].toString();
    }
  }

  bool validateToken() {
    return _pb.authStore.isValid;
  }

  Future<void> refreshToken() async {
    try {
      await _pb.collection("users").authRefresh();
    } catch (_) {}
  }

  void logout() {
    _pb.authStore.clear();
  }

  Future<Map<String, QuizGroup>> getQuizGroups() async {
    try {
      final dbResponse =
          await _pb.collection('quiz_groups').getFullList(fields: "id,name");
      final map = <String, QuizGroup>{};
      for (final field in dbResponse) {
        final id = field.id;
        final name = field.getStringValue("name");
        map[name] = QuizGroup(name: name, id: id);
      }
      return map;
    } on ClientException catch (err) {
      throw err.response["message"].toString();
    }
  }

  Future<String> addQuizGroup(String name) async {
    try {
      final result =
          await _pb.collection("quiz_groups").create(body: {"name": name});
      return result.id;
    } on ClientException catch (err) {
      throw err.response["message"].toString();
    }
  }

  Future<void> removeQuizGroup(String id) async {
    try {
      if (id.trim().isEmpty) {
        throw "Failed to remove group from server. Id was a null";
      }
      await _pb.collection("quiz_groups").delete(id);
    } on ClientException catch (err) {
      throw err.response["message"].toString();
    }
  }

  Future<List<QuizItem>> getQuizItem(String groupId) async {
    try {
      if (groupId.trim().isEmpty) {
        throw "Cannot get quiz_items from server. Group id is null.";
      }

      final dbResponse = await _pb
          .collection('quiz_items')
          .getFullList(filter: "group.id = '$groupId'");

      final result = <QuizItem>[];

      for (final e in dbResponse) {
        final id = e.id;
        final type = QuizItemType.values.elementAtOrNull(e.getIntValue("type"));
        if (type == null) {
          continue;
        }
        final json = e.getDataValue<Map<String, dynamic>>("data");
        final imageFilename = e.getStringValue("image");
        final imageUri = (imageFilename.isNotEmpty)
            ? _pb.files.getUrl(e, imageFilename).toString()
            : null;

        result.add(QuizItem.fromJson(
            type: type, json: json, id: id, imageUri: imageUri));
      }

      return result;
    } on ClientException catch (err) {
      throw err.response["message"].toString();
    }
  }

  Future<String> addQuizItem(
      String groupId, QuizItem item, XFileImage? image) async {
    try {
      if (groupId.trim().isEmpty) {
        throw "Cannot add flashcard. Group Id is null";
      }
      final body = {"group": groupId, ...item.toJson()};

      final files = await _getFileToUpload(image);

      final result =
          await _pb.collection("quiz_items").create(body: body, files: files);
      return result.id;
    } on ClientException catch (err) {
      throw err.response["message"].toString();
    } catch (err) {
      throw "Something went wrong while adding a flashcard :(: $err";
    }
  }

  Future<List<http.MultipartFile>> _getFileToUpload(XFileImage? image) async {
    if (image != null) {
      final stream = image.file.openRead();
      final length = await image.file.length();
      return [http.MultipartFile('image', stream, length, filename: 'test')];
    }

    return [];
  }

  Future<void> removeQuizItem(QuizItem item) async {
    try {
      final id = item.id;
      if (id == null) {
        throw "Cannot remove flashcard. Id is null";
      }

      await _pb.collection("quiz_items").delete(id);
    } on ClientException catch (err) {
      throw err.response["message"].toString();
    }
  }

  Future<void> updateQuizItem(QuizItem item, String groupId) async {
    try {
      final id = item.id;
      if (id == null) {
        item.id = await addQuizItem(groupId, item, null);
        return;
      }

      final body = {"data": item.data.toJson()};

      await _pb.collection("quiz_items").update(id, body: body);
    } on ClientException catch (err) {
      throw err.response["message"].toString();
    }
  }
}
