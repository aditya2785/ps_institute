import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ps_institute/core/constants/firestore_paths.dart';
import 'package:ps_institute/data/models/doubt_model.dart';

class DoubtRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------------------------------------------------
  // Create a new doubt (Student)
  // ---------------------------------------------------------
  Future<void> createDoubt(DoubtModel doubt) async {
    await _db
        .collection(FirestorePaths.doubts)
        .add(doubt.toMap());
  }

  // ---------------------------------------------------------
  // Student: Listen to doubts asked by student
  // ---------------------------------------------------------
  Stream<List<DoubtModel>> listenToStudentDoubts(String studentId) {
    return _db
        .collection(FirestorePaths.doubts)
        .where("studentId", isEqualTo: studentId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => DoubtModel.fromMap(
              doc.data(),
              doc.id,
            ),
          )
          .toList();
    });
  }

  // ---------------------------------------------------------
  // Teacher: Listen to doubts assigned to teacher
  // ---------------------------------------------------------
  Stream<List<DoubtModel>> listenToTeacherDoubts(String teacherId) {
    return _db
        .collection(FirestorePaths.doubts)
        .where("teacherId", isEqualTo: teacherId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => DoubtModel.fromMap(
              doc.data(),
              doc.id,
            ),
          )
          .toList();
    });
  }

  // ---------------------------------------------------------
  // Teacher: Answer a doubt (text and/or file)
  // ---------------------------------------------------------
  Future<void> answerDoubt({
    required String doubtId,
    String? answerText,
    String? answerFileUrl,
  }) async {
    await _db
        .collection(FirestorePaths.doubts)
        .doc(doubtId)
        .update({
      "answerText": answerText,
      "answerFileUrl": answerFileUrl,
      "status": "answered",
      "answeredAt": Timestamp.now(),
    });
  }

  // ---------------------------------------------------------
  // Get a single doubt by ID (optional helper)
  // ---------------------------------------------------------
  Future<DoubtModel?> getDoubtById(String doubtId) async {
    final doc = await _db
        .collection(FirestorePaths.doubts)
        .doc(doubtId)
        .get();

    if (!doc.exists) return null;

    return DoubtModel.fromMap(doc.data()!, doc.id);
  }
}
