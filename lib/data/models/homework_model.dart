import 'package:cloud_firestore/cloud_firestore.dart';

class HomeworkModel {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String className; // ✅ ADD THIS

  final DateTime createdAt;
  final DateTime dueAt;

  final String teacherId;
  final String teacherName;
  final String? fileUrl;

  final int submissions;
  final bool allowResubmission;

  HomeworkModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.className, // ✅
    required this.createdAt,
    required this.dueAt,
    required this.teacherId,
    required this.teacherName,
    this.fileUrl,
    this.submissions = 0,
    required this.allowResubmission,
  });

  factory HomeworkModel.fromMap(Map<String, dynamic> map, String docId) {
    return HomeworkModel(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      subject: map['subject'] ?? '',
      className: map['className'] ?? '', // ✅
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      fileUrl: map['fileUrl'],
      submissions: map['submissions'] ?? 0,
      allowResubmission: map['allowResubmission'] ?? true,
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dueAt:
          (map['dueAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "subject": subject,
      "className": className, // ✅
      "teacherId": teacherId,
      "teacherName": teacherName,
      "fileUrl": fileUrl,
      "submissions": submissions,
      "allowResubmission": allowResubmission,
      "createdAt": Timestamp.fromDate(createdAt),
      "dueAt": Timestamp.fromDate(dueAt),
    };
  }
}
