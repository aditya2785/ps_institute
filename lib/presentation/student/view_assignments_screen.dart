import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ps_institute/core/widgets/loading_indicator.dart';
import 'package:ps_institute/presentation/components/drawer_menu.dart';

import 'package:ps_institute/data/models/user_model.dart';
import 'package:ps_institute/data/repositories/assignment_repo.dart';
import 'package:ps_institute/presentation/components/assignment_tile.dart';

import 'package:ps_institute/presentation/viewmodels/auth_viewmodel.dart';

class ViewAssignmentsScreen extends StatelessWidget {
  const ViewAssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthViewModel>(context);
    final UserModel user = authVm.currentUser!;
    final assignmentRepo = AssignmentRepository();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Assignments"),
      ),
      drawer: DrawerMenu(user: user),

      body: StreamBuilder(
        stream: assignmentRepo.listenToAssignments(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LoadingIndicator();
          }

          final assignments = snapshot.data!;

          // ✅ SAME FILTERING LOGIC AS HOMEWORK
          final filtered = assignments
              .where((a) => a.className == user.studentClass)
              .toList();

          if (filtered.isEmpty) {
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
                      "No assignments available for your class!",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
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
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final assignment = filtered[index];

              return AssignmentTile(
                assignment: assignment,
              );
            },
          );
        },
      ),
    );
  }
}
