import 'package:flutter/material.dart';

// reason why we use map because we want to match the title and the values on it
typedef DialogOptionBuilder<T> = Map<String, T?> Function();

// generic function that can based what you provide it and the same datatype
// called that datatype at T
// every button have a values that you can get from the dialog
Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionBuilder optionsBuilder,
}) {
  final options = optionsBuilder();
  return showDialog<T>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: options.keys.map(
          (optionTitle) {
            // get the values of the keys (optionTitle)
            final value = options[optionTitle];
            return TextButton(
              onPressed: () {
                if (value != null) {
                  Navigator.of(context).pop(value);
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: Text(optionTitle),
            );
          },
        ).toList(),
      );
    },
  );
}
