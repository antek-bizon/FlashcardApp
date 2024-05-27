import 'package:flashcards/cubits/auth.dart';
import 'package:flashcards/data/models/quiz_group.dart';
import 'package:flashcards/data/models/quiz_item.dart';
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
  final Map<String, QuizGroup> groups;
  SuccessGroupState(this.groups);
}

class GroupCubit extends Cubit<GroupState> {
  final DatabaseRepository _dbr;
  final LocalStorageRepository _lsr;
  Map<String, QuizGroup> _groups = {};

  GroupCubit(
      {required DatabaseRepository databaseRepository,
      required LocalStorageRepository localStorageRepository})
      : _dbr = databaseRepository,
        _lsr = localStorageRepository,
        super(InitGroupState());

  void fetchGroups(final AuthState authState) {
    _try(() async {
      final futures = [
        if (isAuth(authState)) _dbr.getQuizGroups(),
        _lsr.getQuizGroups()
      ];
      final results = await Future.wait(futures);
      _groups = _removeGroupDuplicates(results);
      emit(SuccessGroupState(_groups));
    });
  }

  void addGroup(final AuthState authState, String name) {
    _try(() async {
      final id = (isAuth(authState)) ? await _dbr.addQuizGroup(name) : null;
      await _lsr.addQuizGroup(name);
      _groups.putIfAbsent(name, () => QuizGroup(name: name, id: id));
      emit(SuccessGroupState(_groups));
    });
  }

  void removeGroup(final AuthState authState, QuizGroup group) {
    _try(() async {
      final futures = [
        if (isAuth(authState) && group.hasId) _dbr.removeQuizGroup(group.id!),
        _lsr.removeQuizGroup(group.name)
      ];
      await Future.wait(futures);
      _groups.remove(group.name);
      emit(SuccessGroupState(_groups));
    });
  }

  void uploadGroupItems(final AuthState authState, String name) {
    _try(() async {
      if (!isAuth(authState)) {
        throw "Cannot upload group items without authorization";
      }

      final [flashcards as List<QuizItem>, id as String] =
          await Future.wait([_lsr.getQuizItem(name), _dbr.addQuizGroup(name)]);
      _groups[name]?.id = id;
      final requests = flashcards.map((e) => _dbr.addQuizItem(id, e, null));
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

  Map<String, QuizGroup> _removeGroupDuplicates(
      final List<Map<String, QuizGroup>> listWithDuplicates) {
    final Map<String, QuizGroup> result = {};
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
