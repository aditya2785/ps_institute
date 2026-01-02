import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ps_institute/core/constants/firestore_paths.dart';
import 'package:ps_institute/data/models/assignment_model.dart';
import 'package:ps_institute/data/models/submission_model.dart';

class AssignmentRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------------------------------------------------
  // Create Assignment (TEACHER ONLY)
  // ---------------------------------------------------------
  Future<String> createAssignment(AssignmentModel assignment) async {
    final ref = await _db
        .collection(FirestorePaths.assignments)
        .add(assignment.toMap());
    return ref.id;
  }

  Future<String> uploadAssignment(AssignmentModel assignment) async {
    return await createAssignment(assignment);
  }

  // ---------------------------------------------------------
  // Update / Delete Assignment
  // ---------------------------------------------------------
  Future<void> updateAssignment(String id, Map<String, dynamic> data) async {
    await _db.collection(FirestorePaths.assignments).doc(id).update(data);
  }

  Future<void> deleteAssignment(String id) async {
    await _db.collection(FirestorePaths.assignments).doc(id).delete();
  }

  // ---------------------------------------------------------
  // Fetch Assignments
  // ---------------------------------------------------------
  Future<List<AssignmentModel>> getAllAssignments() async {
    final snapshot = await _db
        .collection(FirestorePaths.assignments)
        .orderBy("createdAt", descending: true)
        .get();

    return snapshot.docs
        .map((doc) => AssignmentModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<AssignmentModel>> getAssignmentsByTeacher(
      String teacherId) async {
    final snapshot = await _db
        .collection(FirestorePaths.assignments)
        .where("teacherId", isEqualTo: teacherId)
        .orderBy("createdAt", descending: true)
        .get();

    return snapshot.docs
        .map((doc) => AssignmentModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Stream<List<AssignmentModel>> listenToAssignments() {
    return _db
        .collection(FirestorePaths.assignments)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => AssignmentModel.fromMap(d.data(), d.id))
            .toList());
  }

  // ---------------------------------------------------------
  // ✅ STUDENT: Assignments by CLASS (SAME AS HOMEWORK)
  // ---------------------------------------------------------
  Stream<List<AssignmentModel>> listenAssignmentsByClass(String className) {
    return _db
        .collection(FirestorePaths.assignments)
        .where("className", isEqualTo: className)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AssignmentModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // ---------------------------------------------------------
  // Get Single Assignment
  // ---------------------------------------------------------
  Future<AssignmentModel?> getAssignmentById(String id) async {
    final doc =
        await _db.collection(FirestorePaths.assignments).doc(id).get();
    if (!doc.exists) return null;
    return AssignmentModel.fromMap(doc.data()!, doc.id);
  }

  // ---------------------------------------------------------
  // ✅ SUBMIT ASSIGNMENT (TOP-LEVEL submissions/)
  // ---------------------------------------------------------
  Future<void> submitAssignment({
    required AssignmentModel assignment,
    required SubmissionModel submission,
  }) async {
    // ⏱ Deadline check
    if (DateTime.now().isAfter(assignment.dueDate)) {
      throw Exception("Deadline passed. Submission closed.");
    }

    final submissionsRef =
        _db.collection(FirestorePaths.submissions);

    // 🔎 Check existing submission
    final existing = await submissionsRef
        .where("assignmentId", isEqualTo: assignment.id)
        .where("studentId", isEqualTo: submission.studentId)
        .limit(1)
        .get();

    // 🔁 Resubmission
    if (existing.docs.isNotEmpty) {
      final doc = existing.docs.first;
      final prevAttempt = (doc.data()['attempt'] ?? 1) as int;

      await doc.reference.update({
        ...submission.toMap(),
        "attempt": prevAttempt + 1,
      });
    }
    // 🆕 First submission
    else {
      await submissionsRef.add({
        ...submission.toMap(),
        "assignmentId": assignment.id,
        "attempt": 1,
      });

      await incrementSubmissionCount(assignment.id);
    }
  }

  // ---------------------------------------------------------
  // Increment Submission Count
  // ---------------------------------------------------------
  Future<void> incrementSubmissionCount(String assignmentId) async {
    await _db
        .collection(FirestorePaths.assignments)
        .doc(assignmentId)
        .update({"submissions": FieldValue.increment(1)});
  }
}
