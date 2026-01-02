import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'package:ps_institute/config/app_routes.dart';
import 'package:ps_institute/config/theme.dart';
import 'package:ps_institute/core/utils/notifications.dart';

// Auth
import 'package:ps_institute/presentation/auth/role_selection_screen.dart';
import 'package:ps_institute/presentation/auth/login_screen.dart';
import 'package:ps_institute/presentation/auth/register_screen.dart';

// Teacher
import 'package:ps_institute/presentation/teacher/teacher_dashboard.dart';
import 'package:ps_institute/presentation/teacher/add_assignment_screen.dart';
import 'package:ps_institute/presentation/teacher/add_homework_screen.dart';
import 'package:ps_institute/presentation/teacher/upload_note_screen.dart';
import 'package:ps_institute/presentation/teacher/teacher_profile_screen.dart';
import 'package:ps_institute/presentation/teacher/doubt_detail_teacher_screen.dart';
import 'package:ps_institute/presentation/teacher/teacher_new_doubts_screen.dart';
import 'package:ps_institute/presentation/teacher/teacher_solved_doubts_screen.dart';


// Student
import 'package:ps_institute/presentation/student/student_dashboard.dart';
import 'package:ps_institute/presentation/student/view_assignments_screen.dart';
import 'package:ps_institute/presentation/student/view_homework_screen.dart';
import 'package:ps_institute/presentation/student/view_notes_screen.dart';
import 'package:ps_institute/presentation/student/student_profile_screen.dart';
import 'package:ps_institute/presentation/student/mini_quiz_screen.dart';
import 'package:ps_institute/data/models/assignment_model.dart';
import 'package:ps_institute/presentation/student/submit_assignment_screen.dart';


// Models
import 'package:ps_institute/data/models/doubt_model.dart';

// ViewModels
import 'package:ps_institute/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ps_institute/presentation/viewmodels/user_viewmodel.dart';
import 'package:ps_institute/presentation/viewmodels/assignment_viewmodel.dart';
import 'package:ps_institute/presentation/viewmodels/homework_viewmodel.dart';
import 'package:ps_institute/presentation/viewmodels/notes_viewmodel.dart';
import 'package:ps_institute/presentation/viewmodels/theme_viewmodel.dart';

import 'package:ps_institute/firebase_options.dart';

// ======================================================
// MAIN APP
// ======================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const PSInstituteApp());
}

class PSInstituteApp extends StatelessWidget {
  const PSInstituteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => AssignmentViewModel()),
        ChangeNotifierProvider(create: (_) => HomeworkViewModel()),
        ChangeNotifierProvider(create: (_) => NotesViewModel()),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeVm, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "PS Institute",

            // ✅ REQUIRED
            scaffoldMessengerKey: AppNotifications.messengerKey,

            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeVm.themeMode,

            initialRoute: AppRoutes.splash,

            routes: {
              // Splash
              AppRoutes.splash: (_) => const SplashScreen(),

              // Auth
              AppRoutes.roleSelection: (_) =>
                  const RoleSelectionScreen(),
              AppRoutes.login: (_) => const LoginScreen(),
              AppRoutes.register: (_) => const RegisterScreen(),

              // Teacher
              AppRoutes.teacherDashboard: (_) =>
                  const TeacherDashboard(),
              AppRoutes.addAssignment: (_) =>
                  const AddAssignmentScreen(),
              AppRoutes.addHomework: (_) =>
                  const AddHomeworkScreen(),
              AppRoutes.uploadNote: (_) =>
                  const UploadNoteScreen(),
              AppRoutes.teacherProfile: (_) =>
                  const TeacherProfileScreen(),
              // Teacher - Doubts
              AppRoutes.teacherNewDoubts: (_) =>
                  const TeacherNewDoubtsScreen(),
              AppRoutes.teacherSolvedDoubts: (_) =>
                  const TeacherSolvedDoubtsScreen(),


              // Student
              AppRoutes.studentDashboard: (_) =>
                  const StudentDashboard(),
              AppRoutes.viewAssignments: (_) =>
                  const ViewAssignmentsScreen(),
              AppRoutes.viewHomework: (_) =>
                  const ViewHomeworkScreen(),
              AppRoutes.viewNotes: (_) =>
                  const ViewNotesScreen(),
              AppRoutes.studentProfile: (_) =>
                  const StudentProfileScreen(),
              AppRoutes.submitAssignment: (context) {
  final assignment =
      ModalRoute.of(context)!.settings.arguments as AssignmentModel;
  return SubmitAssignmentScreen(assignment: assignment);
},

              
              AppRoutes.miniQuiz: (_) =>
                  const MiniQuizScreen(),
            },

            // 🔥 SAFE FIX (NULL-PROOF)
            onGenerateRoute: (settings) {
              if (settings.name ==
                  AppRoutes.doubtDetailTeacher) {
                final args = settings.arguments;

                if (args == null || args is! DoubtModel) {
                  return MaterialPageRoute(
                    builder: (_) => const Scaffold(
                      body: Center(
                        child: Text(
                          "Invalid doubt data.\nPlease go back.",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }

                return MaterialPageRoute(
                  builder: (_) =>
                      DoubtDetailTeacherScreen(doubt: args),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}

// ======================================================
// SPLASH SCREEN (UNCHANGED)
// ======================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      Navigator.pushReplacementNamed(
          context, AppRoutes.roleSelection);
      return;
    }

    final authVm =
        Provider.of<AuthViewModel>(context, listen: false);
    await authVm.loadUser(firebaseUser.uid);

    if (!mounted) return;

    if (authVm.currentUser == null) {
      Navigator.pushReplacementNamed(
          context, AppRoutes.roleSelection);
      return;
    }

    if (authVm.currentUser!.role == "teacher") {
      Navigator.pushReplacementNamed(
          context, AppRoutes.teacherDashboard);
    } else {
      Navigator.pushReplacementNamed(
          context, AppRoutes.studentDashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                Column(
                  children: [
                    Image.asset(
                      "assets/images/app_logo.png",
                      height: 130,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "PS Institute",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Padding(
                  padding: EdgeInsets.only(bottom: 22),
                  child: Text(
                    "Developed by Aditya Jha",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
