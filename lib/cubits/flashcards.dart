import 'dart:math';

import 'package:flashcards/cubits/auth.dart';
import 'package:flashcards/data/models/flashcard.dart';
import 'package:flashcards/data/repositories/database.dart';
import 'package:flashcards/data/repositories/localstorage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';

abstract class CardState {}

class InitCardState extends CardState {}

class LoadingCardState extends CardState {}

class ErrorCardState extends CardState {
  final String message;
  ErrorCardState(this.message);
}

class SuccessCardState extends CardState {
  final List<FlashcardModel> flashcards;
  SuccessCardState(this.flashcards);
}

class SuccessGroupState extends CardState {
  final Map<String, FlashcardGroup> groups;
  SuccessGroupState(this.groups);
}

class CardCubit extends Cubit<CardState> {
  final DatabaseRepository _dbr;
  final LocalStorageRepository _lsr;
  Map<String, FlashcardGroup> _groups = {};
  final List<FlashcardModel> _cards = [];

  CardCubit(
      {required DatabaseRepository databaseRepository,
      required LocalStorageRepository localStorageRepository})
      : _dbr = databaseRepository,
        _lsr = localStorageRepository,
        super(InitCardState());

  void fetchGroups(final AuthState authState) {
    _try(() async {
      final futures = [
        if (_isAuth(authState)) _dbr.getFlashcardGroups(),
        _lsr.getFlashcardGroups()
      ];
      final results = await Future.wait(futures);
      _groups = _removeGroupDuplicates(results);
      emit(SuccessGroupState(_groups));
    });
  }

  void addGroup(final AuthState authState, String name) {
    _try(() async {
      final id =
          (_isAuth(authState)) ? await _dbr.addFlashcardGroup(name) : null;
      await _lsr.addFlashcardGroup(name);
      _groups.putIfAbsent(name, () => FlashcardGroup(id));
      emit(SuccessGroupState(_groups));
    });
  }

  void removeGroup(final AuthState authState, String name) {
    _try(() async {
      final futures = [
        if (_isAuth(authState)) _dbr.removeFlashcardGroup(name),
        _lsr.removeGroup(name)
      ];
      await Future.wait(futures);
      _groups.remove(name);
      emit(SuccessGroupState(_groups));
    });
  }

  void getFlashcards(final AuthState authState, String groupName) {
    _try(() async {
      final futures = [
        if (_isAuth(authState)) _dbr.getFlashcards(groupName),
        _lsr.getFlashcards(groupName)
      ];
      final results = await Future.wait(futures);
      _cards.clear();
      _cards.addAll(_removeCardsDuplicates(results));
      emit(SuccessCardState(_cards));
    });
  }

  void addFlashcard(final AuthState authState, String groupName,
      FlashcardModel item, XFileImage? image) {
    _try(() async {
      final id = (_isAuth(authState))
          ? await _dbr.addFlashcard(groupName, item, image)
          : null;
      item.id = id;
      item.image = image?.file.path;
      _cards.add(item);
      await _lsr.updateJson(groupName, _cards);
      emit(SuccessCardState(_cards));
    });
  }

  void removeFlashcard(final AuthState authState, String groupName, int index) {
    _try(() async {
      final item = _cards.removeAt(index);
      final futures = [
        if (_isAuth(authState)) _dbr.removeFlashcard(item),
        _lsr.updateJson(groupName, _cards)
      ];

      await Future.wait(futures);
      emit(SuccessCardState(_cards));
    });
  }

  void uploadGroupItems(final AuthState authState, String name) {
    _try(() async {
      if (_isAuth(authState)) {
        throw "Cannot upload group items without authorization";
      }

      final flashcards = await _lsr.getFlashcards(name);
      final requests = flashcards.map((e) => _dbr.addFlashcard(name, e, null));
      final results = await Future.wait(requests);
      for (int i = 0; i < results.length; i++) {
        flashcards[i].id = results[i];
      }
      await _lsr.updateJson(name, flashcards);
      emit(SuccessGroupState(_groups));
    });
  }

  void _try(Future<void> Function() fun) async {
    emit(LoadingCardState());
    try {
      await fun();
    } catch (e) {
      emit(ErrorCardState(e.toString()));
    }
  }

  bool _isAuth(final AuthState authState) {
    return authState is SuccessAuthState;
  }

  Map<String, FlashcardGroup> _removeGroupDuplicates(
      final List<Map<String, FlashcardGroup>> listWithDuplicates) {
    final Map<String, FlashcardGroup> result = {};
    for (final groupMap in listWithDuplicates) {
      groupMap.forEach((key, value) {
        if (!result.containsKey(key)) {
          result.putIfAbsent(key, () => value);
        }
      });
    }
    return result;
  }

  List<FlashcardModel> _removeCardsDuplicates(
      final List<List<FlashcardModel>> cards) {
    final cardsSet = cards.first.toSet();
    for (int i = 1; i < cards.length; i++) {
      for (var e in cards[i]) {
        if (!cardsSet.contains(e)) {
          cardsSet.add(e);
        }
      }
    }
    return cardsSet.toList();
  }
}
