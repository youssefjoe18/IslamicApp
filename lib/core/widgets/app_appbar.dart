import 'package:flutter/material.dart';

class AppAppBar extends AppBar {
  AppAppBar({super.key, required String titleText})
      : super(
          title: Text(titleText),
        );
}


