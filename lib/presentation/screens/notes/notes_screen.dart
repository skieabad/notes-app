import 'package:flutter/material.dart';

import 'package:notes_app/constants/routes.dart';
import 'package:notes_app/enum/menu_action.dart';
import 'package:notes_app/services/auth/auth_service.dart';
import 'package:notes_app/services/crud/notes_service.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late final NotesService _notesService;
  // get the current user
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: SafeArea(
      // child: Center(
      //   child: Column(
      //     children: [
      //       Align(
      //         alignment: Alignment.topRight,
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.end,
      //           children: [
      //             IconButton(
      //               onPressed: () =>
      //                   Navigator.of(context).pushNamed(newNotesRoute),
      //               icon: const Icon(Icons.add),
      //             ),
      //             PopupMenuButton<MenuAction>(
      //               onSelected: (value) async {
      //                 switch (value) {
      //                   case MenuAction.logout:
      //                     final logout = await showLogOutDialog(context);
      //                     if (logout) {
      //                       await AuthService.firebase().logoutUser();
      //                       'logout'.log();
      //                       Navigator.of(context).pushNamedAndRemoveUntil(
      //                           loginRoute, (route) => false);
      //                     }
      //                     break;
      //                   case MenuAction.settings:
      //                     break;
      //                 }
      //               },
      //               itemBuilder: (context) => <PopupMenuEntry<MenuAction>>[
      //                 const PopupMenuItem<MenuAction>(
      //                   value: MenuAction.logout,
      //                   child: Text('Logout'),
      //                 ),
      //                 const PopupMenuItem<MenuAction>(
      //                   value: MenuAction.settings,
      //                   child: Text('Settings'),
      //                 ),
      //               ],
      //             ),
      //           ],
      //         ),
      //       ),
      //       const SizedBox(
      //         height: 20,
      //       ),
      //       FutureBuilder(
      //         future: _notesService.getOrCreateUser(email: userEmail),
      //         builder: (context, snapshot) {
      //           switch (snapshot.connectionState) {
      //             case ConnectionState.done:
      //               return StreamBuilder(
      //                 stream: _notesService.allNotes,
      //                 builder: (context, snapshot) {
      //                   switch (snapshot.connectionState) {
      //                     // waiting is perfect with stream builder
      //                     case ConnectionState.waiting:
      //                     case ConnectionState.active:
      //                       if (snapshot.hasData) {
      //                         final allNotes =
      //                             snapshot.data as List<DatabaseNotes>;
      //                         return ListView.builder(
      //                           itemCount: allNotes.length,
      //                           itemBuilder: (context, index) {
      //                             final note = allNotes[index];
      //                             return ListTile(
      //                               title: Text(
      //                                 note.text,
      //                               ),
      //                             );
      //                           },
      //                         );
      //                       } else {
      //                         return const Center(
      //                           child: CircularProgressIndicator(),
      //                         );
      //                       }
      //                     default:
      //                       return const Center(
      //                         child: CircularProgressIndicator(),
      //                       );
      //                   }
      //                 },
      //               );
      //             default:
      //               return const Center(
      //                 child: CircularProgressIndicator(),
      //               );
      //           }
      //         },
      //       ),
      //     ],
      //   ),
      // ),
      // ),
      appBar: AppBar(
        title: const Text('Your notes'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(newNotesRoute),
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final logout = await showLogOutDialog(context);
                  if (logout) {
                    await AuthService.firebase().logoutUser();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(loginRoute, (route) => false);
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
        ],
      ),
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    // waiting is perfect with stream builder
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final allNotes = snapshot.data as List<DatabaseNotes>;
                        print(allNotes);
                        return const Center(
                          child: Text('Here are the notes'),
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    default:
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                  }
                },
              );
            default:
              return const Center(
                child: CircularProgressIndicator(),
              );
          }
        },
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
