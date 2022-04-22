import 'package:flutter/material.dart';

void globalSnackBar(String content, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: const Color.fromARGB(255, 246, 20, 3),
      content: Text(content),
      duration: const Duration(seconds: 2),
    ),
  );
}
