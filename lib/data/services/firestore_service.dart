import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------------------------------------------------
  // Get Document by Path
  // ---------------------------------------------------------
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(String path) async {
    return await _db.doc(path).get();
  }

  // ---------------------------------------------------------
  // Get Collection
  // ---------------------------------------------------------
  Future<QuerySnapshot<Map<String, dynamic>>> getCollection(String path) async {
    return await _db.collection(path).get();
  }

  // ---------------------------------------------------------
  // Set Document (Create/Replace)
  // ---------------------------------------------------------
  Future<void> setDocument(
    String path,
    Map<String, dynamic> data, {
    bool merge = true,
  }) async {
    await _db.doc(path).set(data, SetOptions(merge: merge));
  }

  // ---------------------------------------------------------
  // Update Document
  // ---------------------------------------------------------
  Future<void> updateDocument(
      String path, Map<String, dynamic> data) async {
    await _db.doc(path).update(data);
  }

  // ---------------------------------------------------------
  // Delete Document
  // ---------------------------------------------------------
  Future<void> deleteDocument(String path) async {
    await _db.doc(path).delete();
  }

  // ---------------------------------------------------------
  // Real-time Document Listener
  // ---------------------------------------------------------
  Stream<DocumentSnapshot<Map<String, dynamic>>> listenDocument(
      String path) {
    return _db.doc(path).snapshots();
  }

  // ---------------------------------------------------------
  // Real-time Collection Listener
  // ---------------------------------------------------------
  Stream<QuerySnapshot<Map<String, dynamic>>> listenCollection(
      String path) {
    return _db.collection(path).snapshots();
  }

  // ---------------------------------------------------------
  // Query Collection
  // Example usage:
  // firestoreService.query("users", "role", "student");
  // ---------------------------------------------------------
  Future<QuerySnapshot<Map<String, dynamic>>> queryCollection(
      String path, String field, dynamic value) async {
    return await _db.collection(path).where(field, isEqualTo: value).get();
  }

  // ---------------------------------------------------------
  // Query with Ordering
  // ---------------------------------------------------------
  Future<QuerySnapshot<Map<String, dynamic>>> queryCollectionOrdered(
    String path,
    String orderField, {
    bool descending = false,
  }) async {
    return await _db
        .collection(path)
        .orderBy(orderField, descending: descending)
        .get();
  }
}
