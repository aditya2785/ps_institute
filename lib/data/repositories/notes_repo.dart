import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ps_institute/core/constants/firestore_paths.dart';
import 'package:ps_institute/data/models/notes_model.dart';

class NotesRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------------------------------------------------
  // Create Note (Teacher)
  // ---------------------------------------------------------
  Future<String> createNote(NotesModel note) async {
    final ref = await _db
        .collection(FirestorePaths.notes)
        .add(note.toMap());

    return ref.id;
  }

  // ---------------------------------------------------------
  // Update Note
  // ---------------------------------------------------------
  Future<void> updateNote(String id, Map<String, dynamic> data) async {
    await _db.collection(FirestorePaths.notes).doc(id).update(data);
  }

  // ---------------------------------------------------------
  // Delete Note
  // ---------------------------------------------------------
  Future<void> deleteNote(String id) async {
    await _db.collection(FirestorePaths.notes).doc(id).delete();
  }

  // ---------------------------------------------------------
  // Fetch ALL Notes (Admin / ViewModel)
  // ---------------------------------------------------------
  Future<List<NotesModel>> getAllNotes() async {
    final snapshot = await _db
        .collection(FirestorePaths.notes)
        .orderBy("uploadedAt", descending: true)
        .get();

    return snapshot.docs
        .map((doc) => NotesModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // ---------------------------------------------------------
  // Fetch Notes by Teacher
  // ---------------------------------------------------------
  Future<List<NotesModel>> getNotesByTeacher(String teacherId) async {
    final snapshot = await _db
        .collection(FirestorePaths.notes)
        .where("teacherId", isEqualTo: teacherId)
        .orderBy("uploadedAt", descending: true)
        .get();

    return snapshot.docs
        .map((doc) => NotesModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // ---------------------------------------------------------
// ✅ Student Notes by CLASS (SAFE & FINAL)
// ---------------------------------------------------------
Stream<List<NotesModel>> listenNotesByClass(String className) {
  return _db
      .collection(FirestorePaths.notes)
      .where("class", isEqualTo: className) // matches NotesModel
      .orderBy("uploadedAt", descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => NotesModel.fromMap(doc.data(), doc.id))
            .toList(),
      );
}


  // ---------------------------------------------------------
  // STREAM ALL NOTES (Students & Teachers)
  // ---------------------------------------------------------
  Stream<List<NotesModel>> listenToNotes() {
    return _db
        .collection(FirestorePaths.notes)
        .orderBy("uploadedAt", descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NotesModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // ---------------------------------------------------------
  // Get Single Note by ID
  // ---------------------------------------------------------
  Future<NotesModel?> getNoteById(String id) async {
    final doc = await _db.collection(FirestorePaths.notes).doc(id).get();
    if (!doc.exists) return null;

    return NotesModel.fromMap(doc.data()!, doc.id);
  }
}
