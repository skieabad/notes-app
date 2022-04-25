import 'package:flutter/material.dart';

Future<void> showErrorDialog(BuildContext context, String? text) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Align(
          alignment: Alignment.center,
          child: Icon(
            Icons.close,
            color: Color.fromARGB(255, 247, 75, 62),
            size: 70,
          ),
        ),
        content: Text(
          text!,
          textAlign: TextAlign.center,
        ),
        titlePadding: const EdgeInsets.only(top: 12, bottom: 2),
        contentPadding: const EdgeInsets.only(bottom: 24),
        actionsPadding: const EdgeInsets.only(bottom: 0),
        buttonPadding: EdgeInsets.zero,
        actions: [
          Container(
            width: double.infinity,
            height: 50,
            color: const Color.fromARGB(255, 247, 75, 62),
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}