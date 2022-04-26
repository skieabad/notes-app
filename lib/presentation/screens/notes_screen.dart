import 'package:flutter/material.dart';

// extension for logging
import 'dart:developer' as devtools show log;

import 'package:notes_app/constants/routes.dart';
import 'package:notes_app/enum/menu_action.dart';
import 'package:notes_app/services/auth/auth_service.dart';

// to show log
extension Log on Object {
  void log() => devtools.log(toString());
}

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: PopupMenuButton<MenuAction>(
                  onSelected: (value) async {
                    switch (value) {
                      case MenuAction.logout:
                        final logout = await showLogOutDialog(context);
                        logout.log();
                        if (logout) {
                          await AuthService.firebase().logoutUser();
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            loginRoute,
                            (_) => false,
                          );
                        }
                        break;
                      case MenuAction.settings:
                        break;
                    }
                  },
                  itemBuilder: (context) => <PopupMenuEntry<MenuAction>>[
                    const PopupMenuItem<MenuAction>(
                      value: MenuAction.logout,
                      child: Text('Logout'),
                    ),
                    const PopupMenuItem<MenuAction>(
                      value: MenuAction.settings,
                      child: Text('Settings'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> showLogOutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }
}
