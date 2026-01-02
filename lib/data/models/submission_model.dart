import 'package:cloud_firestore/cloud_firestore.dart';

class SubmissionModel {
  final String id;
  final String studentId;
  final String studentName;
  final String? studentImage;
  final String fileUrl;
  final String submissionType; // assignment / homework
  final String parentId;
  final DateTime submittedAt;

  // 🔥 NEW FIELDS
  final bool isLate;
  final int attempt; // resubmission count
  final String? remarks;
  final double? marks;

  SubmissionModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.fileUrl,
    required this.submissionType,
    required this.parentId,
    required this.submittedAt,
    required this.isLate,
    required this.attempt,
    this.studentImage,
    this.remarks,
    this.marks,
  });

  // -----------------------------
  // Firestore → Model
  // -----------------------------
  factory SubmissionModel.fromMap(Map<String, dynamic> map, String docId) {
    return SubmissionModel(
      id: docId,
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      studentImage: map['studentImage'],
      fileUrl: map['fileUrl'] ?? '',
      submissionType: map['submissionType'] ?? 'homework',
      parentId: map['parentId'] ?? '',
      remarks: map['remarks'],
      marks: map['marks'] != null ? (map['marks'] as num).toDouble() : null,
      submittedAt:
          (map['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isLate: map['isLate'] ?? false,
      attempt: map['attempt'] ?? 1,
    );
  }

  // -----------------------------
  // Model → Firestore
  // -----------------------------
  Map<String, dynamic> toMap() {
    return {
      "studentId": studentId,
      "studentName": studentName,
      "studentImage": studentImage,
      "fileUrl": fileUrl,
      "submissionType": submissionType,
      "parentId": parentId,
      "remarks": remarks,
      "marks": marks,
      "submittedAt": Timestamp.fromDate(submittedAt),
      "isLate": isLate,     // 🔥 for stats
      "attempt": attempt,   // 🔥 for resubmission
    };
  }
}
