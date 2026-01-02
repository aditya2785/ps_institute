import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ps_institute/core/constants/firestore_paths.dart';
import 'package:ps_institute/data/models/homework_model.dart';
import 'package:ps_institute/data/models/submission_model.dart';

class HomeworkRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------------------------------------------------
  // Create Homework (TEACHER ONLY)
  // ---------------------------------------------------------
  Future<String> createHomework(HomeworkModel homework) async {
    final ref = await _db
        .collection(FirestorePaths.homework)
        .add(homework.toMap());
    return ref.id;
  }

  Future<String> uploadHomework(HomeworkModel homework) async {
    return await createHomework(homework);
  }

  // ---------------------------------------------------------
  // Update / Delete Homework
  // ---------------------------------------------------------
  Future<void> updateHomework(String id, Map<String, dynamic> data) async {
    await _db.collection(FirestorePaths.homework).doc(id).update(data);
  }

  Future<void> deleteHomework(String id) async {
    await _db.collection(FirestorePaths.homework).doc(id).delete();
  }

  // ---------------------------------------------------------
  // Fetch Homework
  // ---------------------------------------------------------
  Future<List<HomeworkModel>> getAllHomework() async {
    final snapshot = await _db
        .collection(FirestorePaths.homework)
        .orderBy("createdAt", descending: true)
        .get();

    return snapshot.docs
        .map((doc) => HomeworkModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<HomeworkModel>> getHomeworkByTeacher(String teacherId) async {
    final snapshot = await _db
        .collection(FirestorePaths.homework)
        .where("teacherId", isEqualTo: teacherId)
        .orderBy("createdAt", descending: true)
        .get();

    return snapshot.docs
        .map((doc) => HomeworkModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Stream<List<HomeworkModel>> listenToHomework() {
    return _db
        .collection(FirestorePaths.homework)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => HomeworkModel.fromMap(d.data(), d.id))
            .toList());
  }

  Future<HomeworkModel?> getHomeworkById(String id) async {
    final doc = await _db.collection(FirestorePaths.homework).doc(id).get();
    if (!doc.exists) return null;
    return HomeworkModel.fromMap(doc.data()!, doc.id);
  }

  // ---------------------------------------------------------
  // ✅ SUBMIT HOMEWORK (TOP-LEVEL submissions/)
  // ---------------------------------------------------------
  Future<void> submitHomework({
    required HomeworkModel homework,
    required SubmissionModel submission,
  }) async {
    // ⏱ Deadline check
    if (DateTime.now().isAfter(homework.dueAt)) {
      throw Exception("Deadline passed. Submission closed.");
    }

    final submissionsRef =
        _db.collection(FirestorePaths.submissions);

    // 🔎 Check existing submission
    final existing = await submissionsRef
        .where("homeworkId", isEqualTo: homework.id)
        .where("studentId", isEqualTo: submission.studentId)
        .limit(1)
        .get();

    // 🔁 Resubmission
    if (existing.docs.isNotEmpty) {
      if (!homework.allowResubmission) {
        throw Exception("Resubmission is disabled by teacher.");
      }

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
        "homeworkId": homework.id,
        "attempt": 1,
      });

      await incrementSubmissionCount(homework.id);
    }
  }

  // ---------------------------------------------------------
  // 📊 Teacher Stats
  // ---------------------------------------------------------
  Future<Map<String, int>> getSubmissionStats(String homeworkId) async {
    final snapshot = await _db
        .collection(FirestorePaths.submissions)
        .where("homeworkId", isEqualTo: homeworkId)
        .get();

    int onTime = 0;
    int late = 0;

    for (final doc in snapshot.docs) {
      final isLate = doc['isLate'] ?? false;
      isLate ? late++ : onTime++;
    }

    return {
      "onTime": onTime,
      "late": late,
    };
  }

  // ---------------------------------------------------------
  // Increment Submission Count
  // ---------------------------------------------------------
  Future<void> incrementSubmissionCount(String homeworkId) async {
    await _db
        .collection(FirestorePaths.homework)
        .doc(homeworkId)
        .update({"submissions": FieldValue.increment(1)});
  }
}
