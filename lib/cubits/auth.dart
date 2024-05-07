import 'package:bloc/bloc.dart';
import 'package:flashcards/data/repositories/database.dart';

abstract class AuthState {}

class InitAuthState extends AuthState {}

class LoadingAuthState extends AuthState {}

class ErrorAuthState extends AuthState {
  final String message;
  ErrorAuthState(this.message);
}

class SuccessAuthState extends AuthState {
  bool autoLogin;
  SuccessAuthState({this.autoLogin = false});
}

class GuestAuthState extends AuthState {}

// -------------- Cubit ---------------------
class AuthCubit extends Cubit<AuthState> {
  final DatabaseRepository _dbr;
  AuthCubit(DatabaseRepository databaseRepository)
      : _dbr = databaseRepository,
        super(InitAuthState());

  void autoLogin() {
    if (_dbr.validateToken()) {
      emit(SuccessAuthState(autoLogin: true));
      _dbr.refreshToken();
    }
  }

  Future<void> login(String username, String password /*, bool save*/) async {
    emit(LoadingAuthState());
    try {
      await _dbr.login(username, password);
      emit(SuccessAuthState());
    } catch (ex) {
      emit(ErrorAuthState(ex.toString()));
    }
  }

  void guestLogin() {
    emit(GuestAuthState());
  }

  void logout() {
    emit(LoadingAuthState());
    _dbr.logout();
    emit(InitAuthState());
  }
}
