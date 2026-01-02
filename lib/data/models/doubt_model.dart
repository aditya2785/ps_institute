import 'package:cloud_firestore/cloud_firestore.dart';

class DoubtModel {
  final String id;

  // =========================
  // Student info
  // =========================
  final String studentId;
  final String studentName;
  final String studentClass;

  // =========================
  // Teacher info (OPTIONAL for backward compatibility)
  // =========================
  final String? teacherId;
  final String? teacherName;

  // =========================
  // Doubt content
  // =========================
  final String subject;
  final String topic;
  final String questionText;
  final String? questionFileUrl;

  // =========================
  // Answer content
  // =========================
  final String? answerText;
  final String? answerFileUrl;

  // =========================
  // Status
  // =========================
  final String status; // "pending" | "answered"

  // =========================
  // Timestamps
  // =========================
  final DateTime createdAt;
  final DateTime? answeredAt;

  DoubtModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentClass,
    this.teacherId,
    this.teacherName,
    required this.subject,
    required this.topic,
    required this.questionText,
    this.questionFileUrl,
    this.answerText,
    this.answerFileUrl,
    required this.status,
    required this.createdAt,
    this.answeredAt,
  });

  // -------------------------------------------------
  // Firestore → Model (🔥 SAFE)
  // -------------------------------------------------
  factory DoubtModel.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return DoubtModel(
      id: documentId,

      // Student
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      studentClass: data['studentClass'] ?? '',

      // Teacher (optional)
      teacherId: data['teacherId'],
      teacherName: data['teacherName'],

      // Content
      subject: data['subject'] ?? '',
      topic: data['topic'] ?? '',
      questionText: data['questionText'] ?? '',
      questionFileUrl: data['questionFileUrl'],

      // Answer
      answerText: data['answerText'],
      answerFileUrl: data['answerFileUrl'],

      // Status
      status: data['status'] ?? 'pending',

      // Time
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),

      answeredAt: data['answeredAt'] is Timestamp
          ? (data['answeredAt'] as Timestamp).toDate()
          : null,
    );
  }

  // -------------------------------------------------
  // Model → Firestore
  // -------------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      "studentId": studentId,
      "studentName": studentName,
      "studentClass": studentClass,

      // Teacher (write only if present)
      if (teacherId != null) "teacherId": teacherId,
      if (teacherName != null) "teacherName": teacherName,

      "subject": subject,
      "topic": topic,
      "questionText": questionText,
      "questionFileUrl": questionFileUrl,

      "answerText": answerText,
      "answerFileUrl": answerFileUrl,

      "status": status,
      "createdAt": Timestamp.fromDate(createdAt),
      "answeredAt":
          answeredAt != null ? Timestamp.fromDate(answeredAt!) : null,
    };
  }

  // -------------------------------------------------
  // Helper getters (UI friendly)
  // -------------------------------------------------
  bool get isAnswered => status == "answered";
  bool get isPending => status == "pending";
}
