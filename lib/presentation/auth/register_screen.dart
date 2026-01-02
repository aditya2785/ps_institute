import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:ps_institute/core/utils/validators.dart';
import 'package:ps_institute/core/utils/notifications.dart';
import 'package:ps_institute/core/widgets/app_button.dart';
import 'package:ps_institute/core/widgets/app_textfield.dart';
import 'package:ps_institute/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ps_institute/config/app_routes.dart';

enum RegisterMethod { email, phone }

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  RegisterMethod selectedMethod = RegisterMethod.email;

  final formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final otpCtrl = TextEditingController();

  bool otpSent = false;
  late final String role;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    role = ModalRoute.of(context)?.settings.arguments as String? ?? "student";
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    phoneCtrl.dispose();
    otpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Image.asset("assets/images/app_logo.png", height: 90),
                const SizedBox(height: 12),

                Text(
                  role == "teacher"
                      ? "Teacher Registration"
                      : "Student Registration",
                  style: theme.textTheme.headlineLarge,
                ),

                const SizedBox(height: 20),

                // 🚫 BLOCK TEACHER SELF-REGISTER UI
                if (role == "teacher")
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Teachers can only register using an authorized email.\n"
                      "If you are not authorized, registration will fail.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),

                const SizedBox(height: 20),

                AppTextField(
                  label: "Full Name",
                  controller: nameCtrl,
                  validator: Validators.name,
                ),

                const SizedBox(height: 20),

                AppTextField(
                  label: "Email",
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),

                AppTextField(
                  label: "Password",
                  controller: passwordCtrl,
                  isPassword: true,
                ),

                const SizedBox(height: 24),

                AppButton(
                  label: "Create Account",
                  isLoading: authVm.isLoading,
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    final success = await authVm.register(
                      name: nameCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      password: passwordCtrl.text.trim(),
                      role: role,
                      context: context,
                    );

                    if (!success) return;

                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null && !user.emailVerified) {
                      await user.sendEmailVerification();
                      await FirebaseAuth.instance.signOut();

                      AppNotifications.showSuccess(
                        context,
                        "Verification email sent. Please verify before login.",
                      );

                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.login,
                        arguments: role, // 🔥 PASS ROLE
                      );
                    }
                  },
                ),

                const SizedBox(height: 30),

                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.login,
                      arguments: role, // 🔥 PASS ROLE
                    );
                  },
                  child: Text(
                    "Already have an account? Login",
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.primary,
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
}
