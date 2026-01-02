import 'dart:io';
import 'package:flutter/material.dart';

import 'package:ps_institute/data/models/assignment_model.dart';
import 'package:ps_institute/data/repositories/assignment_repo.dart';
import 'package:ps_institute/data/services/storage_service.dart';

class AssignmentViewModel extends ChangeNotifier {
  final AssignmentRepository _repo = AssignmentRepository();

  bool isLoading = false;
  List<AssignmentModel> assignments = [];

  // -------------------------------------------------------
  // STREAM ASSIGNMENTS (Real-time updates)
  // -------------------------------------------------------
  Stream<List<AssignmentModel>> listenToAssignments() {
    return _repo.listenToAssignments();
  }

  // -------------------------------------------------------
  // FETCH ASSIGNMENTS (One-time, optional / admin)
  // -------------------------------------------------------
  Future<void> fetchAssignments() async {
    try {
      isLoading = true;
      notifyListeners();

      assignments = await _repo.getAllAssignments();
    } catch (e) {
      debugPrint("Error fetching assignments: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // -------------------------------------------------------
  // CREATE ASSIGNMENT (Teacher)
  // -------------------------------------------------------
  Future<String?> createAssignment({
    required String title,
    required String description,
    required String subject,
    required String className,
    required DateTime dueDate,
    required String teacherId,
    required String teacherName,
    required File file,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      // 1️⃣ Upload file to Firebase Storage
      final fileUrl = await StorageService().uploadFile(
        folder: "assignments",
        file: file,
        uid: teacherId,
      );

      // 2️⃣ Auto-close at EXACT midnight (same as homework)
      final dueAt = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        23,
        59,
        59,
      );

      // 3️⃣ Build Assignment model (CLEAN & COMPLETE)
      final assignment = AssignmentModel(
        id: "", // Firestore will generate
        title: title,
        description: description,
        subject: subject,
        className: className.trim(), // ✅ IMPORTANT
        createdAt: DateTime.now(),
        dueDate: dueAt,
        teacherId: teacherId,
        teacherName: teacherName,
        fileUrl: fileUrl,
        submissions: 0,
      );

      // 4️⃣ Save to Firestore
      await _repo.createAssignment(assignment);

      return null;
    } catch (e) {
      debugPrint("Create assignment error: $e");
      return e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // -------------------------------------------------------
  // DELETE ASSIGNMENT
  // -------------------------------------------------------
  Future<void> deleteAssignment(String assignmentId) async {
    try {
      await _repo.deleteAssignment(assignmentId);
    } catch (e) {
      debugPrint("Error deleting assignment: $e");
    }
  }

  // -------------------------------------------------------
  // INCREMENT SUBMISSION COUNT
  // -------------------------------------------------------
  Future<void> incrementSubmission(String assignmentId) async {
    try {
      await _repo.incrementSubmissionCount(assignmentId);
    } catch (e) {
      debugPrint("Error incrementing submissions: $e");
    }
  }
}
