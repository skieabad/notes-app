import 'package:flutter/material.dart';

abstract class StatelessWidgetBase extends StatelessWidget {
  final String? title;
  const StatelessWidgetBase({Key? key, this.title}) : super(key: key);
}
