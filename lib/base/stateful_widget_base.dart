import 'package:flutter/material.dart';

abstract class StatefulWidgetBase extends StatefulWidget {
  final String? title;
  const StatefulWidgetBase({Key? key, this.title}) : super(key: key);
}
