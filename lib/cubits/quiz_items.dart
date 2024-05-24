import 'package:flashcards/cubits/auth.dart';
import 'package:flashcards/data/models/quiz_item.dart';
import 'package:flashcards/data/repositories/database.dart';
import 'package:flashcards/data/repositories/localstorage.dart';
import 'package:flashcards/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';

abstract class QuizItemState {}

class InitItemState extends QuizItemState {}

class LoadingItemState extends QuizItemState {}

class ErrorItemState extends QuizItemState {
  final String message;
  ErrorItemState(this.message);
}

class SuccessItemState extends QuizItemState {
  final List<QuizItem> flashcards;
  SuccessItemState(this.flashcards);
}

class QuizItemCubit extends Cubit<QuizItemState> {
  final DatabaseRepository _dbr;
  final LocalStorageRepository _lsr;
  final List<QuizItem> _cards = [];

  QuizItemCubit(
      {required DatabaseRepository databaseRepository,
      required LocalStorageRepository localStorageRepository})
      : _dbr = databaseRepository,
        _lsr = localStorageRepository,
        super(InitItemState());

  void getQuizItem(AuthState authState, String groupName, String? groupId) {
    _try(() async {
      final futures = [
        if (isAuth(authState) && groupId != null) _dbr.getQuizItem(groupId),
        _lsr.getQuizItem(groupName)
      ];
      final results = await Future.wait(futures);
      _cards.clear();
      _cards.addAll(_removeCardsDuplicates(results));
      emit(SuccessItemState(_cards));
    });
  }

  void addQuizItem(
      {required AuthState authState,
      required String groupName,
      String? groupId,
      required QuizItem item,
      XFileImage? image}) {
    _try(() async {
      final id = (isAuth(authState) && groupId != null)
          ? await _dbr.addQuizItem(groupId, item, image)
          : null;
      item.id = id;
      item.imageUri = image?.file.path;
      _cards.add(item);
      await _lsr.updateJson(groupName, _cards);
      emit(SuccessItemState(_cards));
    });
  }

  void removeQuizItem(
      AuthState authState, String groupName, int index, bool hasGroupId) {
    _try(() async {
      final item = _cards.removeAt(index);
      final futures = [
        if (isAuth(authState) && hasGroupId && item.id != null)
          _dbr.removeQuizItem(item),
        _lsr.updateJson(groupName, _cards)
      ];

      await Future.wait(futures);
      emit(SuccessItemState(_cards));
    });
  }

  void updateQuizItem(
      AuthState authState, String groupName, int index, String? groupId) {
    _try(() async {
      final item = _cards.elementAt(index);
      final futures = [
        if (isAuth(authState) && groupId != null)
          _dbr.updateQuizItem(item, groupId),
        _lsr.updateJson(groupName, _cards)
      ];

      await Future.wait(futures);
      emit(SuccessItemState(_cards));
    });
  }

  void _try(Future<void> Function() fun) async {
    emit(LoadingItemState());
    try {
      await fun();
    } catch (e) {
      emit(ErrorItemState(e.toString()));
    }
  }

  List<QuizItem> _removeCardsDuplicates(final List<List<QuizItem>> cards) {
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
