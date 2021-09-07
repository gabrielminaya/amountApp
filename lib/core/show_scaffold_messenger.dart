import 'package:flutter/material.dart';

void showScaffoldMessenger({required BuildContext context, required String message}) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: "CERRAR",
        onPressed: () {
          ScaffoldMessenger.of(context).clearSnackBars();
        },
      ),
    ),
  );
}
