import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:ps_institute/data/models/user_model.dart';
import 'package:ps_institute/data/repositories/user_repo.dart';

import 'package:ps_institute/config/app_routes.dart';
import 'package:ps_institute/core/utils/notifications.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepo = UserRepository();

  UserModel? currentUser;
  bool isLoading = false;

  // -----------------------------------------------------------
  // LOAD USER DETAILS FROM FIRESTORE
  // -----------------------------------------------------------
  Future<void> loadUser(String uid) async {
    currentUser = await _userRepo.getUser(uid);
    notifyListeners();
  }

  // -----------------------------------------------------------
  // REFRESH USER AFTER PROFILE UPDATE
  // -----------------------------------------------------------
  Future<void> refreshUser() async {
    if (_auth.currentUser == null) return;
    await loadUser(_auth.currentUser!.uid);
  }

  // -----------------------------------------------------------
  // REGISTER
  // -----------------------------------------------------------
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required BuildContext context,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final trimmedEmail = email.trim().toLowerCase();

      // 🔐 TEACHER WHITELIST CHECK
      if (role == "teacher") {
        final snapshot = await FirebaseFirestore.instance
            .collection("teacher_whitelist")
            .where("email", isEqualTo: trimmedEmail)
            .limit(1)
            .get();

        if (snapshot.docs.isEmpty) {
          AppNotifications.showError(
            context,
            "You are not authorized to register as a teacher.",
          );
          return false;
        }
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: password.trim(),
      );

      final uid = credential.user!.uid;

      final user = UserModel(
        uid: uid,
        name: name.trim(),
        email: trimmedEmail,
        phone: "",
        role: role,
        createdAt: DateTime.now(),
        profileImage: null,
        studentClass: null,
        teacherSubject: null,
      );

      await _userRepo.createUser(user);
      await loadUser(uid);

      return true;
    } on FirebaseAuthException catch (e) {
      AppNotifications.showError(
        context,
        e.message ?? "Registration failed",
      );
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // -----------------------------------------------------------
  // 🔥 LOGIN WITH ROLE VALIDATION (CRITICAL FIX)
  // -----------------------------------------------------------
  Future<bool> login({
    required String email,
    required String password,
    required String expectedRole,
    required BuildContext context,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = credential.user!.uid;
      await loadUser(uid);

      // 🚨 ROLE MISMATCH BLOCK
      if (currentUser == null || currentUser!.role != expectedRole) {
        await _auth.signOut();

        AppNotifications.showError(
          context,
          expectedRole == "teacher"
              ? "You are not authorized as a teacher."
              : "You are not authorized as a student.",
        );
        return false;
      }

      _redirectToDashboard(context, currentUser!.role);
      return true;
    } on FirebaseAuthException catch (e) {
      AppNotifications.showError(
        context,
        e.message ?? "Login failed",
      );
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // -----------------------------------------------------------
  // GOOGLE SIGN-IN (ROLE SELECTED AFTER FIRST LOGIN)
  // -----------------------------------------------------------
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await _auth.signInWithCredential(credential);
      final uid = userCred.user!.uid;

      final exists = await _userRepo.userExists(uid);

      if (!exists) {
        Navigator.pushNamed(context, AppRoutes.roleSelection);
      } else {
        await loadUser(uid);
        _redirectToDashboard(context, currentUser!.role);
      }
    } catch (e) {
      AppNotifications.showError(context, e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // -----------------------------------------------------------
  // LOGOUT
  // -----------------------------------------------------------
  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    currentUser = null;
    notifyListeners();

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (_) => false,
    );
  }

  // -----------------------------------------------------------
  // REDIRECT USER BASED ON ROLE
  // -----------------------------------------------------------
  void _redirectToDashboard(BuildContext context, String role) {
    if (role == "teacher") {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.teacherDashboard,
        (_) => false,
      );
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.studentDashboard,
        (_) => false,
      );
    }
  }
}
