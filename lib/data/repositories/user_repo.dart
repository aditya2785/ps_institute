import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ps_institute/core/constants/firestore_paths.dart';
import 'package:ps_institute/data/models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------------------------------------------------
  // Create User Document (ONLY ON REGISTER)
  // ---------------------------------------------------------
  Future<void> createUser(UserModel user) async {
    await _db
        .collection(FirestorePaths.users)
        .doc(user.uid)
        .set(user.toMap(), SetOptions(merge: true));
  }

  // ---------------------------------------------------------
  // Update User (🔥 SAFE — NEVER TOUCH ROLE)
  // ---------------------------------------------------------
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    // 🔒 Prevent role tampering (rules depend on it)
    data.remove("role");

    await _db
        .collection(FirestorePaths.users)
        .doc(uid)
        .update(data);
  }

  // ---------------------------------------------------------
  // Get User by UID
  // ---------------------------------------------------------
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db
        .collection(FirestorePaths.users)
        .doc(uid)
        .get();

    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, uid);
  }

  // ---------------------------------------------------------
  // Real-time User Listener
  // ---------------------------------------------------------
  Stream<UserModel?> listenToUser(String uid) {
    return _db
        .collection(FirestorePaths.users)
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!, doc.id);
    });
  }

  // ---------------------------------------------------------
  // Get All Students (ordered list — requires index)
  // ---------------------------------------------------------
  Future<List<UserModel>> getAllStudents() async {
    final snapshot = await _db
        .collection(FirestorePaths.users)
        .where("role", isEqualTo: "student")
        .orderBy("createdAt", descending: true)
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // ---------------------------------------------------------
  // Get All Teachers (🔥 NO orderBy → NO index issue)
  // ---------------------------------------------------------
  Future<List<UserModel>> getAllTeachers() async {
    final snapshot = await _db
        .collection(FirestorePaths.users)
        .where("role", isEqualTo: "teacher")
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // ---------------------------------------------------------
  // Check if User Exists
  // ---------------------------------------------------------
  Future<bool> userExists(String uid) async {
    final doc = await _db
        .collection(FirestorePaths.users)
        .doc(uid)
        .get();

    return doc.exists;
  }
}
