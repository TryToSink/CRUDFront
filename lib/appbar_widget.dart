import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:crud1310/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

AppBar buildAppBar(BuildContext context) {
  bool isDarkMode = false;
  final icon = isDarkMode ? CupertinoIcons.sun_max : CupertinoIcons.moon_stars;

  return AppBar(
    leading: const BackButton(
      color: Colors.black,
    ),
    elevation: 0,
    backgroundColor: Colors.transparent,
    actions: [
      ThemeSwitcher(
        builder: (context) => IconButton(
          icon: Icon(icon, color: Colors.black),
          onPressed: () {
            isDarkMode == false ? isDarkMode = true : isDarkMode = false;
            final theme = isDarkMode ? MyThemes.lightTheme : MyThemes.darkTheme;
            final switcher = ThemeSwitcher.of(context)!;
            switcher.changeTheme(theme: theme);
          },
        ),
      ),
    ],
  );
}