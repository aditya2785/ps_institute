import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'package:ps_institute/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ps_institute/presentation/student/student_dashboard.dart';
import 'package:ps_institute/presentation/teacher/teacher_dashboard.dart';
import 'package:ps_institute/presentation/auth/role_selection_screen.dart';


class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Provider.of<AuthViewModel>(context, listen: false)
          .loadUser(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthViewModel>(context);

    // ✅ NOT LOGGED IN → ROLE SELECTION
    if (FirebaseAuth.instance.currentUser == null) {
      return const RoleSelectionScreen();
    }

    // ✅ LOGGED IN BUT USER DATA STILL LOADING
    if (authVm.currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ✅ LOGGED IN + ROLE BASED DASHBOARD
    return authVm.currentUser!.role == "teacher"
        ? const TeacherDashboard()
        : const StudentDashboard();
  }
}
