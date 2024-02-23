import 'package:flutter/material.dart';

SnackBar quickSnack(final String msg) {
  return SnackBar(
      content: Text(
    msg,
    textAlign: TextAlign.center,
  ));
}
