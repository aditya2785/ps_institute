import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ps_institute/core/utils/notifications.dart';
import 'package:ps_institute/core/widgets/app_button.dart';
import 'package:ps_institute/core/widgets/app_textfield.dart';
import 'package:ps_institute/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ps_institute/config/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  late final String expectedRole; // "teacher" or "student"

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 🔐 ROLE PASSED FROM ROLE SELECTION
    expectedRole =
        ModalRoute.of(context)?.settings.arguments as String? ?? "student";
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
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
          child: Column(
            children: [
              const SizedBox(height: 30),

              Image.asset("assets/images/app_logo.png", height: 90),
              const SizedBox(height: 16),

              Text(
                expectedRole == "teacher"
                    ? "Teacher Login"
                    : "Student Login",
                style: theme.textTheme.headlineLarge,
              ),

              const SizedBox(height: 40),

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

              const SizedBox(height: 30),

              AppButton(
                label: "Login",
                isLoading: authVm.isLoading,
                onPressed: () async {
                  if (emailCtrl.text.isEmpty ||
                      passwordCtrl.text.isEmpty) {
                    AppNotifications.showError(
                      context,
                      "Email and password required",
                    );
                    return;
                  }

                  // 🔐 ROLE-LOCKED LOGIN (CORE FIX)
                  final success = await authVm.login(
                    email: emailCtrl.text.trim(),
                    password: passwordCtrl.text.trim(),
                    expectedRole: expectedRole,
                    context: context,
                  );

                  if (!success) return;
                },
              ),

              const SizedBox(height: 30),

              // 🚫 TEACHERS SHOULD NOT REGISTER
              if (expectedRole == "student")
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.register,
                      arguments: "student",
                    );
                  },
                  child: Text(
                    "Don't have an account? Register",
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
    );
  }
}
