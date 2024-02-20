import 'package:flashcards/model/exceptions.dart';
import 'package:flutter/material.dart';

SnackBar quickSnack(final String msg) {
  return SnackBar(
      content: Text(
    msg,
    textAlign: TextAlign.center,
  ));
}

SnackBar errorSnack(final ExceptionMessage msg) {
  return SnackBar(
      content: Text(
    msg.toString(),
    textAlign: TextAlign.center,
  ));
}
