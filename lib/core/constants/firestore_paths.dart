class FirestorePaths {
  // -------------------------
  // Users
  // -------------------------
  static const String users = "users";
  static String userDoc(String uid) => "users/$uid";

  // -------------------------
  // Assignments
  // -------------------------
  static const String assignments = "assignments";
  static String assignmentDoc(String assignmentId) =>
      "assignments/$assignmentId";
  static String assignmentSubmissions(String assignmentId) =>
      "assignments/$assignmentId/submissions";

  // -------------------------
  // Homework
  // -------------------------
  static const String homework = "homework";
  static String homeworkDoc(String homeworkId) =>
      "homework/$homeworkId";
  static String homeworkSubmissions(String homeworkId) =>
      "homework/$homeworkId/submissions";

  // -------------------------
  // Notes
  // -------------------------
  static const String notes = "notes";
  static String notesDoc(String noteId) => "notes/$noteId";

  // -------------------------
  // Submissions (Global)
  // -------------------------
  static const String submissions = "submissions";
  static String submissionDoc(String submissionId) =>
      "submissions/$submissionId";

  // -------------------------
  // Doubts ✅ (NEW)
  // -------------------------
  static const String doubts = "doubts";
  static String doubtDoc(String doubtId) =>
      "doubts/$doubtId";
}
