import 'dart:io';
import 'package:flutter/material.dart';

import 'package:ps_institute/data/models/doubt_model.dart';
import 'package:ps_institute/data/repositories/doubt_repo.dart';
import 'package:ps_institute/data/services/storage_service.dart';

class DoubtViewModel extends ChangeNotifier {
  final DoubtRepository _repo = DoubtRepository();
  final StorageService _storageService = StorageService();

  bool isLoading = false;
  List<DoubtModel> doubts = [];

  // -------------------------------------------------------
  // STUDENT: LISTEN TO MY DOUBTS (Real-time)
  // -------------------------------------------------------
  Stream<List<DoubtModel>> listenToStudentDoubts(String studentId) {
    return _repo.listenToStudentDoubts(studentId);
  }

  // -------------------------------------------------------
  // TEACHER: LISTEN TO ASSIGNED DOUBTS (Real-time)
  // -------------------------------------------------------
  Stream<List<DoubtModel>> listenToTeacherDoubts(String teacherId) {
    return _repo.listenToTeacherDoubts(teacherId);
  }

  // -------------------------------------------------------
  // STUDENT: CREATE DOUBT
  // -------------------------------------------------------
  Future<String?> createDoubt({
    required String studentId,
    required String studentName,
    required String studentClass,
    required String teacherId,
    required String teacherName,
    required String subject,
    required String topic,
    required String questionText,
    File? questionFile,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      String? fileUrl;

      // 1️⃣ Upload question file (optional)
      if (questionFile != null) {
        fileUrl = await _storageService.uploadDoubtFile(
          questionFile,
          studentId,
        );
      }

      // 2️⃣ Build doubt model
      final doubt = DoubtModel(
        id: "", // Firestore auto ID
        studentId: studentId,
        studentName: studentName,
        studentClass: studentClass,
        teacherId: teacherId,
        teacherName: teacherName,
        subject: subject,
        topic: topic,
        questionText: questionText.trim(),
        questionFileUrl: fileUrl,
        answerText: null,
        answerFileUrl: null,
        status: "pending",
        createdAt: DateTime.now(),
        answeredAt: null,
      );

      // 3️⃣ Save to Firestore
      await _repo.createDoubt(doubt);

      return null;
    } catch (e) {
      debugPrint("Create doubt error: $e");
      return e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // -------------------------------------------------------
  // TEACHER: ANSWER DOUBT
  // -------------------------------------------------------
  Future<String?> answerDoubt({
    required String doubtId,
    required String teacherId,
    String? answerText,
    File? answerFile,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      String? fileUrl;

      // 1️⃣ Upload answer file (optional)
      if (answerFile != null) {
        fileUrl = await _storageService.uploadDoubtAnswerFile(
          file: answerFile,
          teacherId: teacherId,
          doubtId: doubtId,
        );
      }

      // 2️⃣ Update doubt
      await _repo.answerDoubt(
        doubtId: doubtId,
        answerText: answerText?.trim().isNotEmpty == true
            ? answerText!.trim()
            : null,
        answerFileUrl: fileUrl,
      );

      return null;
    } catch (e) {
      debugPrint("Answer doubt error: $e");
      return e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // -------------------------------------------------------
  // OPTIONAL: FETCH DOUBT BY ID
  // -------------------------------------------------------
  Future<DoubtModel?> getDoubtById(String doubtId) async {
    try {
      return await _repo.getDoubtById(doubtId);
    } catch (e) {
      debugPrint("Get doubt error: $e");
      return null;
    }
  }
}
