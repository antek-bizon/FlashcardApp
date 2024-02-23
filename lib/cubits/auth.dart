import 'package:bloc/bloc.dart';

abstract class AuthState {}

class InitAuthState extends AuthState {}

class LoadingAuthState extends AuthState {}

class ErrorAuthState extends AuthState {
  final String message;
  ErrorAuthState(this.message);
}

class SuccessAuthState extends AuthState {}

class GuestAuthState extends AuthState {}

// -------------- Cubit ---------------------
class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(InitAuthState());

  void login(String username, String password) {
    emit(SuccessAuthState());
  }

  void guestLogin() {
    emit(GuestAuthState());
  }

  void logout() {
    emit(InitAuthState());
  }
}
