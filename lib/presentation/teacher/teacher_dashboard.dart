import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ps_institute/config/palette.dart';
import 'package:ps_institute/presentation/components/drawer_menu.dart';

import 'package:ps_institute/data/models/user_model.dart';

import 'package:ps_institute/config/app_routes.dart';
import 'package:ps_institute/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ps_institute/presentation/viewmodels/theme_viewmodel.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();

    if (authVm.currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final UserModel teacher = authVm.currentUser!;
    final themeVm = context.watch<ThemeViewModel>();
    final isDark = themeVm.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Dashboard"),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: themeVm.toggleTheme,
          ),
        ],
      ),
      drawer: DrawerMenu(user: teacher),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= WELCOME =================
            Text(
              "Welcome, ${teacher.name}",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            Text(
              teacher.teacherSubject == null
                  ? "Subject: Not assigned yet"
                  : "Subject: ${teacher.teacherSubject}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 28),

            // ================= QUICK ACTIONS =================
            Text(
              "Quick Actions",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                _quickActionCard(
                  context: context,
                  icon: Icons.assignment_add,
                  label: "Add Assignment",
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.addAssignment),
                ),
                const SizedBox(width: 16),
                _quickActionCard(
                  context: context,
                  icon: Icons.note_add,
                  label: "Add Homework",
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.addHomework),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _quickActionCard(
              context: context,
              icon: Icons.upload_file,
              label: "Upload Notes",
              wide: true,
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.uploadNote),
            ),

            const SizedBox(height: 32),

            // ================= DOUBTS =================
            Text(
              "Student Doubts",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                _statusCard(
                  context,
                  icon: Icons.mark_chat_unread,
                  label: "View New Doubts",
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.teacherNewDoubts, // ✅ FIXED
                    );
                  },
                ),
                const SizedBox(width: 16),
                _statusCard(
                  context,
                  icon: Icons.check_circle,
                  label: "View Solved Doubts",
                  color: Colors.green,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.teacherSolvedDoubts, // ✅ FIXED
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ================= QUICK ACTION CARD =================
  Widget _quickActionCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool wide = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    final cardWidth = wide
        ? screenWidth - 36
        : (screenWidth - 36 - 16) / 2;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isDark
              ? Palette.secondary.withOpacity(0.18)
              : Palette.secondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: Palette.secondary),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  // ================= DOUBT STATUS CARD =================
  Widget _statusCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 10),
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
