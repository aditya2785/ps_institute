import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import 'package:ps_institute/data/models/homework_model.dart';
import 'package:ps_institute/data/models/submission_model.dart';
import 'package:ps_institute/data/repositories/homework_repo.dart';
import 'package:ps_institute/data/services/storage_service.dart';

import 'package:ps_institute/core/utils/notifications.dart';
import 'package:ps_institute/core/widgets/app_button.dart';
import 'package:ps_institute/core/widgets/app_card.dart';
import 'package:ps_institute/presentation/viewmodels/auth_viewmodel.dart';

class SubmitHomeworkScreen extends StatefulWidget {
  final HomeworkModel homework;

  const SubmitHomeworkScreen({
    super.key,
    required this.homework,
  });

  @override
  State<SubmitHomeworkScreen> createState() => _SubmitHomeworkScreenState();
}

class _SubmitHomeworkScreenState extends State<SubmitHomeworkScreen> {
  File? selectedFile;
  bool isSubmitting = false;

  bool get isDeadlinePassed {
    return DateTime.now().isAfter(widget.homework.dueAt);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().currentUser!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Submit Homework")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= HOMEWORK DETAILS =================
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.homework.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.homework.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 15,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Subject: ${widget.homework.subject}",
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Due: ${widget.homework.dueAt.toLocal().toString().split(' ')[0]}",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDeadlinePassed
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurface,
                      fontWeight:
                          isDeadlinePassed ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ================= DEADLINE WARNING =================
            if (isDeadlinePassed)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "⛔ Deadline has passed. Submission is closed.",
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            if (!isDeadlinePassed) ...[
              const SizedBox(height: 30),

              // ================= FILE PICK =================
              Text(
                "Upload Homework",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              GestureDetector(
                onTap: pickFile,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: theme.dividerColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.upload_file,
                        size: 28,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selectedFile != null
                              ? selectedFile!.path.split('/').last
                              : "Tap to upload PDF / Image",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 15,
                            color: selectedFile != null
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ================= SUBMIT BUTTON =================
              AppButton(
                label: "Submit / Resubmit Homework",
                isLoading: isSubmitting,
                onPressed: selectedFile == null
                    ? null
                    : () => submitHomework(
                          studentId: user.uid,
                          studentName: user.name,
                          image: user.profileImage,
                        ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ================= FILE PICKER =================
  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["pdf", "jpg", "jpeg", "png"],
    );

    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  // ================= SUBMIT LOGIC =================
  Future<void> submitHomework({
    required String studentId,
    required String studentName,
    required String? image,
  }) async {
    if (selectedFile == null) return;

    setState(() => isSubmitting = true);

    try {
      final fileUrl = await StorageService().uploadSubmission(
        file: selectedFile!,
        uid: studentId,
        parentId: widget.homework.id,
      );

      final submission = SubmissionModel(
        id: "",
        studentId: studentId,
        studentName: studentName,
        studentImage: image,
        fileUrl: fileUrl,
        submissionType: "homework",
        parentId: widget.homework.id,
        submittedAt: DateTime.now(),
        isLate: DateTime.now().isAfter(widget.homework.dueAt),
        attempt: 1,
      );

      await HomeworkRepository().submitHomework(
        homework: widget.homework,
        submission: submission,
      );

      AppNotifications.showSuccess(
        context,
        "Homework submitted successfully!",
      );

      Navigator.pop(context);
    } catch (e) {
      AppNotifications.showError(context, e.toString());
    }

    setState(() => isSubmitting = false);
  }
}
