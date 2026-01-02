import 'package:cloud_firestore/cloud_firestore.dart';

class NotesModel {
  final String id;
  final String title;
  final String description;
  final String subject;

  final String className; // ✅ REQUIRED (same as homework/assignment)

  final String teacherId;
  final String teacherName;
  final String fileUrl;
  final DateTime uploadedAt;

  NotesModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.className, // ✅ REQUIRED
    required this.teacherId,
    required this.teacherName,
    required this.fileUrl,
    required this.uploadedAt,
  });

  // ---------------------------------------------------------
  // Firestore → Model
  // ---------------------------------------------------------
  factory NotesModel.fromMap(Map<String, dynamic> map, String docId) {
    return NotesModel(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      subject: map['subject'] ?? '',
      className: map['className'] ?? '', // ✅ CONSISTENT
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      uploadedAt:
          (map['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // ---------------------------------------------------------
  // Model → Firestore
  // ---------------------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "subject": subject,
      "className": className, // ✅ CONSISTENT
      "teacherId": teacherId,
      "teacherName": teacherName,
      "fileUrl": fileUrl,
      "uploadedAt": Timestamp.fromDate(uploadedAt),
    };
  }
}
