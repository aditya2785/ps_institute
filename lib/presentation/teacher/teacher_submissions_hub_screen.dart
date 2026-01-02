import 'package:flutter/material.dart';
import 'submission_parent_list_screen.dart';

class TeacherSubmissionsHubScreen extends StatelessWidget {
  const TeacherSubmissionsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Submissions"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _card(
              context,
              title: "Assignment Submissions",
              icon: Icons.assignment,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        SubmissionParentListScreen(type: "assignment"),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _card(
              context,
              title: "Homework Submissions",
              icon: Icons.book,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        SubmissionParentListScreen(type: "homework"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isDark
              ? theme.colorScheme.secondary.withOpacity(0.18)
              : theme.colorScheme.primary.withOpacity(0.1),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 30,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
