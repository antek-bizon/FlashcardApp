import 'dart:io';

import 'package:flashcards/cubits/auth.dart';
import 'package:flutter/foundation.dart';
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

bool isWebUrl(String uri) {
  Uri parsedUri = Uri.parse(uri);
  return parsedUri.scheme == 'http' || parsedUri.scheme == 'https';
}

Widget? getImage(String? uri) {
  try {
    if (uri == null || uri.isEmpty) {
      return null;
    }

    if (isWebUrl(uri)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          uri,
          fit: BoxFit.contain,
        ),
      );
    }

    if (kIsWeb) {
      return null;
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.file(
        File(uri),
        fit: BoxFit.contain,
      ),
    );
  } catch (ex) {
    return null;
  }
}
