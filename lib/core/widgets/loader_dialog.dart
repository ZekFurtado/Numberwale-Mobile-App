import 'package:flutter/material.dart';

class LoaderDialog extends StatelessWidget {
  const LoaderDialog({super.key, required this.title});

  final String title;

  static void show(BuildContext context, {String title = 'Loading...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoaderDialog(title: title),
    );
  }

  static void hide(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 50,
        child: AlertDialog(
          title: Text(title),
          content: const LinearProgressIndicator(),
        ));
  }
}
