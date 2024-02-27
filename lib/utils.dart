import 'package:flashcards/cubits/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

SizedBox addSpacing({double? width, double? height}) {
  return SizedBox(
    width: width ?? 0,
    height: height ?? 0,
  );
}

AuthState authState(BuildContext context) =>
    BlocProvider.of<AuthCubit>(context).state;

bool isAuth(final AuthState authState) {
  return authState is SuccessAuthState;
}
