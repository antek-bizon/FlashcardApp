import 'package:flashcards/cubits/auth.dart';
import 'package:flashcards/data/models/flashcard.dart';
import 'package:flashcards/data/repositories/database.dart';
import 'package:flashcards/data/repositories/localstorage.dart';
import 'package:flashcards/utils.dart';
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

class CardCubit extends Cubit<CardState> {
  final DatabaseRepository _dbr;
  final LocalStorageRepository _lsr;
  final List<FlashcardModel> _cards = [];

  CardCubit(
      {required DatabaseRepository databaseRepository,
      required LocalStorageRepository localStorageRepository})
      : _dbr = databaseRepository,
        _lsr = localStorageRepository,
        super(InitCardState());

  void getFlashcards(AuthState authState, String groupName, String? groupId) {
    _try(() async {
      final futures = [
        if (isAuth(authState) && groupId != null) _dbr.getFlashcards(groupId),
        _lsr.getFlashcards(groupName)
      ];
      final results = await Future.wait(futures);
      _cards.clear();
      _cards.addAll(_removeCardsDuplicates(results));
      emit(SuccessCardState(_cards));
    });
  }

  void addFlashcard(
      {required AuthState authState,
      required String groupName,
      String? groupId,
      required FlashcardModel item,
      XFileImage? image}) {
    _try(() async {
      final id = (isAuth(authState) && groupId != null)
          ? await _dbr.addFlashcard(groupId, item, image)
          : null;
      item.id = id;
      item.imageUri = image?.file.path;
      _cards.add(item);
      await _lsr.updateJson(groupName, _cards);
      emit(SuccessCardState(_cards));
    });
  }

  void removeFlashcard(
      AuthState authState, String groupName, int index, bool hasGroupId) {
    _try(() async {
      final item = _cards.removeAt(index);
      final futures = [
        if (isAuth(authState) && hasGroupId) _dbr.removeFlashcard(item),
        _lsr.updateJson(groupName, _cards)
      ];

      await Future.wait(futures);
      emit(SuccessCardState(_cards));
    });
  }

  void updateFlashcard(
      AuthState authState, String groupName, int index, String? groupId) {
    _try(() async {
      final item = _cards.elementAt(index);
      final futures = [
        if (isAuth(authState) && groupId != null)
          _dbr.updateFlashcard(item, groupId),
        _lsr.updateJson(groupName, _cards)
      ];

      await Future.wait(futures);
      emit(SuccessCardState(_cards));
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
