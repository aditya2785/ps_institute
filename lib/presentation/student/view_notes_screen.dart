import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ps_institute/core/widgets/loading_indicator.dart';
import 'package:ps_institute/presentation/components/drawer_menu.dart';

import 'package:ps_institute/data/models/user_model.dart';
import 'package:ps_institute/presentation/components/notes_tile.dart';

import 'package:ps_institute/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ps_institute/presentation/viewmodels/notes_viewmodel.dart';

class ViewNotesScreen extends StatelessWidget {
  const ViewNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final notesVm = context.read<NotesViewModel>();
    final UserModel user = authVm.currentUser!;
    final theme = Theme.of(context);

    // ---------------------------------------------------
    // ✅ HANDLE NULL / EMPTY CLASS SAFELY
    // ---------------------------------------------------
    if (user.studentClass == null || user.studentClass!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Notes")),
        drawer: DrawerMenu(user: user),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Text(
              "Please select your class to view notes.",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Notes")),
      drawer: DrawerMenu(user: user),

      // ---------------------------------------------------
      // ✅ LISTEN ONLY TO STUDENT'S CLASS NOTES
      // ---------------------------------------------------
      body: StreamBuilder(
        stream: notesVm.listenNotesByClass(user.studentClass!),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LoadingIndicator();
          }

          final notes = snapshot.data!;

          if (notes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/empty_state.png",
                      height: 150,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "No notes available for your class!",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        color:
                            theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              return NotesTile(
                note: notes[index],
              );
            },
          );
        },
      ),
    );
  }
}
