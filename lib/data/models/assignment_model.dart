import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentModel {
  final String id;
  final String title;
  final String description;
  final String subject;

  // ✅ SAME AS HOMEWORK
  final String className;

  final DateTime createdAt;
  final DateTime dueDate;

  final String teacherId;
  final String teacherName;
  final String? fileUrl;

  final int submissions;

  AssignmentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.className, // ✅ SAME FIELD
    required this.createdAt,
    required this.dueDate,
    required this.teacherId,
    required this.teacherName,
    this.fileUrl,
    this.submissions = 0,
  });

  // ---------------------------------------------------------
  // Convert Firestore Document to Model
  // ---------------------------------------------------------
  factory AssignmentModel.fromMap(Map<String, dynamic> map, String docId) {
    return AssignmentModel(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      subject: map['subject'] ?? '',
      className: map['className'] ?? '', // ✅ SAME AS HOMEWORK
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      fileUrl: map['fileUrl'],
      submissions: map['submissions'] ?? 0,
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dueDate:
          (map['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // ---------------------------------------------------------
  // Convert Model to Map (for uploading to Firestore)
  // ---------------------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "subject": subject,
      "className": className, // ✅ SAME AS HOMEWORK
      "teacherId": teacherId,
      "teacherName": teacherName,
      "fileUrl": fileUrl,
      "submissions": submissions,
      "createdAt": Timestamp.fromDate(createdAt),
      "dueDate": Timestamp.fromDate(dueDate),
    };
  }
}
