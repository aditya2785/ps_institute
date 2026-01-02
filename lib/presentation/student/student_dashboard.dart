import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ps_institute/config/palette.dart';
import 'package:ps_institute/presentation/components/drawer_menu.dart';

import 'package:ps_institute/data/models/user_model.dart';

import 'package:ps_institute/presentation/student/ask_doubt_screen.dart';
import 'package:ps_institute/presentation/student/my_doubts_screen.dart';

import 'package:ps_institute/config/app_routes.dart';
import 'package:ps_institute/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ps_institute/presentation/viewmodels/theme_viewmodel.dart';

import 'package:ps_institute/core/utils/streak_manager.dart';
import 'package:ps_institute/core/utils/daily_brain_booster.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _streak = 0;
  late BrainBoosterQuestion _todayQuestion;

  @override
  void initState() {
    super.initState();
    _loadEngagementData();
  }

  Future<void> _loadEngagementData() async {
    final streak = await StreakManager.updateAndGetStreak();
    setState(() {
      _streak = streak;
      _todayQuestion = DailyBrainBooster.getTodayQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();

    if (authVm.currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final UserModel user = authVm.currentUser!;
    final themeVm = context.watch<ThemeViewModel>();
    final isDark = themeVm.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Dashboard"),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: themeVm.toggleTheme,
          ),
        ],
      ),
      drawer: DrawerMenu(user: user),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= WELCOME =================
            Text(
              "Welcome, ${user.name}",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            Text(
              "Class: ${user.studentClass ?? "Not Set"}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 24),

            // ================= STREAK =================
            _infoCard(
              icon: Icons.local_fire_department,
              title: "Learning Streak",
              subtitle: "$_streak day${_streak == 1 ? '' : 's'} in a row",
              color: Colors.orange,
            ),

            const SizedBox(height: 16),

            // ================= BRAIN BOOSTER =================
            _actionCard(
              icon: Icons.psychology,
              title: "Daily Brain Booster",
              subtitle: _todayQuestion.question,
              onTap: () => _showBrainBoosterDialog(context),
            ),

            const SizedBox(height: 16),

            // ================= MINI QUIZ =================
            _actionCard(
              icon: Icons.quiz,
              title: "Mini Quiz Mode",
              subtitle: "5 quick questions • No pressure",
              onTap: () => Navigator.pushNamed(context, AppRoutes.miniQuiz),
            ),

            const SizedBox(height: 32),

            // ================= EXPLORE =================
            Text(
              "Explore",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _quickCard(
                    context,
                    icon: Icons.assignment,
                    label: "Assignments",
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.viewAssignments),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _quickCard(
                    context,
                    icon: Icons.book,
                    label: "Homework",
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.viewHomework),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _quickCard(
              context,
              icon: Icons.note_alt,
              label: "Notes",
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.viewNotes),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _quickCard(
                    context,
                    icon: Icons.help_outline,
                    label: "Ask a Doubt",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AskDoubtScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _quickCard(
                    context,
                    icon: Icons.question_answer,
                    label: "My Doubts",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyDoubtsScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ================= UI HELPERS =================
  Widget _infoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Palette.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: Palette.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, maxLines: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surfaceVariant
              : theme.colorScheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: theme.colorScheme.primary),
            const SizedBox(height: 10),
            Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBrainBoosterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_todayQuestion.question),
        content: Text(
          "Answer: ${_todayQuestion.answer}\n\n${_todayQuestion.explanation}",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Got it"),
          ),
        ],
      ),
    );
  }
}
