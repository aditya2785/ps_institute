import 'package:flutter/material.dart';
import 'package:ps_institute/config/app_routes.dart';
import 'package:ps_institute/config/palette.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text("Select Role"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset("assets/images/app_logo.png", height: 100),
            const SizedBox(height: 20),

            Text(
              "Welcome to PS Institute",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Choose your role to continue",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 40),

            // -------------------------
            // TEACHER → LOGIN ONLY
            // -------------------------
            _roleCard(
              context,
              title: "I'm a Teacher",
              subtitle: "Login with your authorized teacher account",
              image: "assets/images/teacher_banner.png",
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.login,
                  arguments: "teacher",
                );
              },
            ),

            const SizedBox(height: 20),

            // -------------------------
            // STUDENT → REGISTER
            // -------------------------
            _roleCard(
              context,
              title: "I'm a Student",
              subtitle: "Register or login as a student",
              image: "assets/images/student_banner.png",
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.register,
                  arguments: "student",
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // ROLE CARD WIDGET (DARK MODE SAFE)
  // ---------------------------------------------------------
  Widget _roleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String image,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surface
              : Palette.background,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios,
              color: Palette.primary,
              size: 18,
            )
          ],
        ),
      ),
    );
  }
}
