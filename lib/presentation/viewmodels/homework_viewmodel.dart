import 'dart:io';
import 'package:flutter/material.dart';

import 'package:ps_institute/data/models/homework_model.dart';
import 'package:ps_institute/data/repositories/homework_repo.dart';
import 'package:ps_institute/data/services/storage_service.dart';

class HomeworkViewModel extends ChangeNotifier {
  final HomeworkRepository _repo = HomeworkRepository();

  bool isLoading = false;
  List<HomeworkModel> homeworks = [];

  // -------------------------------------------------------
  // STREAM HOMEWORK (Real-time updates)
  // -------------------------------------------------------
  Stream<List<HomeworkModel>> listenToHomework() {
    return _repo.listenToHomework();
  }

  // -------------------------------------------------------
  // FETCH HOMEWORK (One-time)
  // -------------------------------------------------------
  Future<void> fetchHomework() async {
    try {
      isLoading = true;
      notifyListeners();

      homeworks = await _repo.getAllHomework();
    } catch (e) {
      debugPrint("Error fetching homework: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // -------------------------------------------------------
  // CREATE HOMEWORK (Teacher)
  // -------------------------------------------------------
  Future<String?> createHomework({
    required String title,
    required String description,
    required String subject,
    required String className,
    required DateTime dueDate,
    required String teacherId,
    required String teacherName,
    required File file,
    bool allowResubmission = true,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      // 1️⃣ Upload file to Firebase Storage
      final fileUrl = await StorageService().uploadFile(
        folder: "homework",
        file: file,
        uid: teacherId,
      );

      // 2️⃣ Auto-close at EXACT midnight
      final dueAt = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        23,
        59,
        59,
      );

      // 3️⃣ Build Homework model (CLEAN & COMPLETE)
      final homework = HomeworkModel(
        id: "", // Firestore will generate
        title: title,
        description: description,
        subject: subject,
        className: className.trim(), // ✅ IMPORTANT
        createdAt: DateTime.now(),
        dueAt: dueAt,
        teacherId: teacherId,
        teacherName: teacherName,
        fileUrl: fileUrl,
        submissions: 0,
        allowResubmission: allowResubmission,
      );

      // 4️⃣ Save to Firestore (GLOBAL collection)
      await _repo.createHomework(homework);

      return null;
    } catch (e) {
      debugPrint("Create homework error: $e");
      return e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // -------------------------------------------------------
  // DELETE HOMEWORK
  // -------------------------------------------------------
  Future<void> deleteHomework(String homeworkId) async {
    try {
      await _repo.deleteHomework(homeworkId);
    } catch (e) {
      debugPrint("Error deleting homework: $e");
    }
  }

  // -------------------------------------------------------
  // INCREMENT SUBMISSION COUNT
  // -------------------------------------------------------
  Future<void> incrementSubmission(String homeworkId) async {
    try {
      await _repo.incrementSubmissionCount(homeworkId);
    } catch (e) {
      debugPrint("Error incrementing submissions: $e");
    }
  }
}
