import 'package:flashcards/cubits/auth.dart';
import 'package:flashcards/data/models/flashcard.dart';
import 'package:flashcards/data/repositories/database.dart';
import 'package:flashcards/data/repositories/localstorage.dart';
import 'package:flashcards/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class GroupState {}

class InitGroupState extends GroupState {}

class LoadingGroupState extends GroupState {}

class ErrorGroupState extends GroupState {
  final String message;
  ErrorGroupState(this.message);
}

class SuccessGroupState extends GroupState {
  final Map<String, FlashcardGroup> groups;
  SuccessGroupState(this.groups);
}

class GroupCubit extends Cubit<GroupState> {
  final DatabaseRepository _dbr;
  final LocalStorageRepository _lsr;
  Map<String, FlashcardGroup> _groups = {};

  GroupCubit(
      {required DatabaseRepository databaseRepository,
      required LocalStorageRepository localStorageRepository})
      : _dbr = databaseRepository,
        _lsr = localStorageRepository,
        super(InitGroupState());

  void fetchGroups(final AuthState authState) {
    _try(() async {
      final futures = [
        if (isAuth(authState)) _dbr.getFlashcardGroups(),
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
          (isAuth(authState)) ? await _dbr.addFlashcardGroup(name) : null;
      await _lsr.addFlashcardGroup(name);
      _groups.putIfAbsent(name, () => FlashcardGroup(id));
      emit(SuccessGroupState(_groups));
    });
  }

  void removeGroup(final AuthState authState, String name, String? id) {
    _try(() async {
      final futures = [
        if (isAuth(authState) && id != null) _dbr.removeFlashcardGroup(id),
        _lsr.removeGroup(name)
      ];
      await Future.wait(futures);
      _groups.remove(name);
      emit(SuccessGroupState(_groups));
    });
  }

  void uploadGroupItems(final AuthState authState, String name) {
    _try(() async {
      if (!isAuth(authState)) {
        throw "Cannot upload group items without authorization";
      }

      final [flashcards as List<FlashcardModel>, id as String] =
          await Future.wait(
              [_lsr.getFlashcards(name), _dbr.addFlashcardGroup(name)]);
      _groups[name]?.id = id;
      final requests = flashcards.map((e) => _dbr.addFlashcard(id, e, null));
      final results = await Future.wait(requests);
      for (int i = 0; i < results.length; i++) {
        flashcards[i].id = results[i];
      }
      await _lsr.updateJson(name, flashcards);
      emit(SuccessGroupState(_groups));
    });
  }

  void _try(Future<void> Function() fun) async {
    emit(LoadingGroupState());
    try {
      await fun();
    } catch (e) {
      emit(ErrorGroupState(e.toString()));
    }
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
}
