import 'dart:async';

import 'package:flashcards/data/models/flashcard.dart';
import 'package:flashcards/presentation/widgets/colorful_textfield/colorful_text_editing_controller.dart';
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

  Future<Map<String, FlashcardGroup>> getFlashcardGroups() async {
    try {
      final dbResponse = await _pb
          .collection('flashcard_groups')
          .getFullList(fields: "id,name");
      final map = <String, FlashcardGroup>{};
      for (final field in dbResponse) {
        final id = field.id;
        final flashcardGroupName = field.getStringValue("name");
        map[flashcardGroupName] = FlashcardGroup(id);
      }
      return map;
    } on ClientException catch (err) {
      throw err.response["message"].toString();
    }
  }

  Future<String> addFlashcardGroup(String name) async {
    try {
      final result =
          await _pb.collection("flashcard_groups").create(body: {"name": name});
      return result.id;
    } on ClientException catch (err) {
      throw err.response["message"].toString();
    }
  }

  Future<void> removeFlashcardGroup(String id) async {
    try {
      if (id.trim().isEmpty) {
        throw "Failed to remove group from server. Id was a null";
      }
      await _pb.collection("flashcard_groups").delete(id);
    } on ClientException catch (err) {
      throw err.response["message"].toString();
    }
  }

  Future<List<FlashcardModel>> getFlashcards(String groupId) async {
    try {
      if (groupId.trim().isEmpty) {
        throw "Cannot get flashcards from server. Group id is null.";
      }

      final dbResponse = await _pb
          .collection('flashcards')
          .getFullList(filter: "flashcard_group.id = '$groupId'");

      return dbResponse.map<FlashcardModel>((e) {
        final id = e.id;
        final question = e.getStringValue("question");
        final answer = e.getStringValue("answer");
        final imageFilename = e.getStringValue("image");
        final imageUri = (imageFilename.isNotEmpty)
            ? _pb.files.getUrl(e, imageFilename)
            : null;
        final styleListData = e.getListValue("style_list");
        final styleList = (styleListData.isNotEmpty &&
                styleListData.first != null)
            ? StylesList.fromRanges(styleListData.cast<List>(), answer.length)
            : null;

        return FlashcardModel(
            question: question,
            answer: answer,
            id: id,
            imageUri: (imageUri != null) ? imageUri.toString() : null,
            styles: styleList);
      }).toList();
    } on ClientException catch (err) {
      throw err.response["message"].toString();
    }
  }

  Future<String> addFlashcard(
      String groupId, FlashcardModel item, XFileImage? image) async {
    try {
      if (groupId.trim().isEmpty) {
        throw "Cannot add flashcard. Group Id is null";
      }
      final body = {
        "question": item.question,
        "answer": item.answer,
        "flashcard_group": groupId,
        "style_list": item.styles?.toJson()
      };

      final files = await _getFileToUpload(image);

      final result =
          await _pb.collection("flashcards").create(body: body, files: files);
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

  Future<void> removeFlashcard(FlashcardModel item) async {
    try {
      final id = item.id;
      if (id == null) {
        throw "Cannot remove flashcard. Id is null";
      }

      await _pb.collection("flashcards").delete(id);
    } on ClientException catch (err) {
      throw err.response["message"].toString();
    }
  }

  Future<void> updateFlashcard(FlashcardModel item, String groupId) async {
    try {
      final id = item.id;
      if (id == null) {
        item.id = await addFlashcard(groupId, item, null);
        return;
      }

      final body = {
        "question": item.question,
        "answer": item.answer,
        "style_list": item.styles?.toJson()
      };

      //if (item.styleList != null)

      await _pb.collection("flashcards").update(id, body: body);
    } on ClientException catch (err) {
      throw err.response["message"].toString();
    }
  }
}
