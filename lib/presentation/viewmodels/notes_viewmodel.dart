import 'dart:io';
import 'package:flutter/material.dart';

import 'package:ps_institute/data/models/notes_model.dart';
import 'package:ps_institute/data/repositories/notes_repo.dart';
import 'package:ps_institute/data/services/storage_service.dart';

class NotesViewModel extends ChangeNotifier {
  final NotesRepository _repo = NotesRepository();

  bool isLoading = false;
  List<NotesModel> notes = [];

  // -------------------------------------------------------
  // ✅ LISTEN NOTES BY CLASS (STUDENT SAFE)
  // -------------------------------------------------------
  Stream<List<NotesModel>> listenNotesByClass(String className) {
    return _repo.listenToNotes().map((allNotes) {
      return allNotes
          .where((note) =>
              note.className == null || note.className == className)
          .toList();
    });
  }

  // -------------------------------------------------------
  // CREATE NOTES (Teacher)
  // -------------------------------------------------------
  Future<String?> uploadNotes({
    required String title,
    required String description,
    required String subject,
    required String className,
    required String teacherId,
    required String teacherName,
    required File file,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      // 1️⃣ Upload file to Firebase Storage
      final fileUrl = await StorageService().uploadFile(
        folder: "notes",
        file: file,
        uid: teacherId,
      );

      // 2️⃣ Build Notes model (CLEAN & SAFE)
      final note = NotesModel(
        id: "",
        title: title,
        description: description,
        subject: subject,
        className: className.trim(),
        teacherId: teacherId,
        teacherName: teacherName,
        fileUrl: fileUrl,
        uploadedAt: DateTime.now(),
      );

      // 3️⃣ Save to Firestore
      await _repo.createNote(note);

      return null;
    } catch (e) {
      debugPrint("Create note error: $e");
      return e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // -------------------------------------------------------
  // DELETE NOTE
  // -------------------------------------------------------
  Future<void> deleteNote(String noteId) async {
    try {
      await _repo.deleteNote(noteId);
    } catch (e) {
      debugPrint("Error deleting note: $e");
    }
  }
}
