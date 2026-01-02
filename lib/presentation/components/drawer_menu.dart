import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ps_institute/config/app_routes.dart';
import 'package:ps_institute/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ps_institute/data/models/user_model.dart';
import 'package:ps_institute/presentation/teacher/teacher_submissions_hub_screen.dart';


class DrawerMenu extends StatelessWidget {
  final UserModel user;

  const DrawerMenu({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final authVm = context.read<AuthViewModel>();
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= HEADER =================
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
            accountName: Text(
              user.name,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            accountEmail: Text(
              user.email,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimary.withOpacity(0.9),
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: theme.colorScheme.onPrimary,
              backgroundImage: user.profileImage != null
                  ? NetworkImage(user.profileImage!)
                  : const AssetImage(
                      "assets/images/profile_default.png",
                    ) as ImageProvider,
            ),
          ),

          // ================= STUDENT =================
          if (user.role == "student") ...[
            _menuItem(
              context,
              icon: Icons.home,
              label: "Dashboard",
              onTap: () => _navigate(context, AppRoutes.studentDashboard),
            ),
            _menuItem(
              context,
              icon: Icons.assignment,
              label: "Assignments",
              onTap: () => _navigate(context, AppRoutes.viewAssignments),
            ),
            _menuItem(
              context,
              icon: Icons.book,
              label: "Homework",
              onTap: () => _navigate(context, AppRoutes.viewHomework),
            ),
            _menuItem(
              context,
              icon: Icons.note_alt,
              label: "Notes",
              onTap: () => _navigate(context, AppRoutes.viewNotes),
            ),
            _menuItem(
              context,
              icon: Icons.person,
              label: "Profile",
              onTap: () => _navigate(context, AppRoutes.studentProfile),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                "Class: ${user.studentClass ?? "Not set"}",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            const Divider(),
          ],

          // ================= TEACHER =================
          if (user.role == "teacher") ...[
            _menuItem(
              context,
              icon: Icons.dashboard,
              label: "Dashboard",
              onTap: () => _navigate(context, AppRoutes.teacherDashboard),
            ),
            _menuItem(
              context,
              icon: Icons.assignment_add,
              label: "Add Assignment",
              onTap: () => _navigate(context, AppRoutes.addAssignment),
            ),
            _menuItem(
              context,
              icon: Icons.note_add,
              label: "Add Homework",
              onTap: () => _navigate(context, AppRoutes.addHomework),
            ),
            _menuItem(
              context,
              icon: Icons.upload_file,
              label: "Upload Notes",
              onTap: () => _navigate(context, AppRoutes.uploadNote),
            ),
_menuItem(
  context,
  icon: Icons.checklist,
  label: "Submissions",
  onTap: () {
    Navigator.pop(context); // close drawer
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TeacherSubmissionsHubScreen(),
      ),
    );
  },
),

            _menuItem(
              context,
              icon: Icons.person,
              label: "Profile",
              onTap: () => _navigate(context, AppRoutes.teacherProfile),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                "Subject: ${user.teacherSubject ?? "Not set"}",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            const Divider(),
          ],

          const Spacer(),

          // ================= LOGOUT =================
          _menuItem(
            context,
            icon: Icons.logout,
            label: "Logout",
            color: theme.colorScheme.error,
            onTap: () async {
              Navigator.pop(context);
              await authVm.logout(context);
            },
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // ================= HELPERS =================

  void _navigate(BuildContext context, String route) {
    Navigator.pop(context);
    Navigator.pushNamed(context, route);
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: theme.colorScheme.primary,
      ),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: color ?? theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
