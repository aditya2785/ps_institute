import 'package:flutter/material.dart';

import 'package:ps_institute/data/models/user_model.dart';
import 'package:ps_institute/data/repositories/user_repo.dart';
import 'package:ps_institute/data/services/storage_service.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepository _repo = UserRepository();

  bool isLoading = false;
  UserModel? user;

  // ------------------------------------------------------------
  // LOAD USER
  // ------------------------------------------------------------
  Future<void> loadUser(String uid) async {
    try {
      isLoading = true;
      notifyListeners();

      user = await _repo.getUser(uid);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("User load error: $e");
      isLoading = false;
      notifyListeners();
    }
  }

  // ------------------------------------------------------------
  // UPDATE USER (SAFE FOR STUDENT & TEACHER)
  // ------------------------------------------------------------
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      isLoading = true;
      notifyListeners();

      // 🔐 Only allowed fields should be passed from UI
      await _repo.updateUser(uid, data);

      // Reload updated user
      user = await _repo.getUser(uid);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("User update error: $e");
      isLoading = false;
      notifyListeners();
      rethrow; // 👈 lets UI show correct error if needed
    }
  }

  // ------------------------------------------------------------
  // UPDATE STUDENT CLASS
  // ------------------------------------------------------------
  Future<void> updateStudentClass(String uid, String newClass) async {
    try {
      isLoading = true;
      notifyListeners();

      await _repo.updateUser(uid, {
        "studentClass": newClass,
      });

      user = await _repo.getUser(uid);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Class update error: $e");
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // ------------------------------------------------------------
  // UPDATE TEACHER SUBJECT
  // ------------------------------------------------------------
  Future<void> updateTeacherSubject(String uid, String subject) async {
    try {
      isLoading = true;
      notifyListeners();

      await _repo.updateUser(uid, {
        "teacherSubject": subject,
      });

      user = await _repo.getUser(uid);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Subject update error: $e");
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // ------------------------------------------------------------
  // UPDATE PROFILE IMAGE (Cloudinary)
  // ------------------------------------------------------------
  Future<void> updateProfileImage(String uid, dynamic file) async {
    try {
      isLoading = true;
      notifyListeners();

      final url = await StorageService().uploadProfileImage(file, uid);

      await _repo.updateUser(uid, {
        "profileImage": url,
      });

      user = await _repo.getUser(uid);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Profile update error: $e");
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
