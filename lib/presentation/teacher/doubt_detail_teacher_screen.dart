import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:ps_institute/core/widgets/app_button.dart';
import 'package:ps_institute/core/widgets/app_textfield.dart';
import 'package:ps_institute/core/utils/notifications.dart';

import 'package:ps_institute/data/models/doubt_model.dart';
import 'package:ps_institute/data/repositories/doubt_repo.dart';
import 'package:ps_institute/data/services/storage_service.dart';

class DoubtDetailTeacherScreen extends StatefulWidget {
  final DoubtModel doubt;

  const DoubtDetailTeacherScreen({
    super.key,
    required this.doubt,
  });

  @override
  State<DoubtDetailTeacherScreen> createState() =>
      _DoubtDetailTeacherScreenState();
}

class _DoubtDetailTeacherScreenState
    extends State<DoubtDetailTeacherScreen> {
  final TextEditingController answerCtrl = TextEditingController();

  File? answerFile;
  bool isLoading = false;

  final DoubtRepository _doubtRepo = DoubtRepository();
  final StorageService _storageService = StorageService();

  bool get isAnswered => widget.doubt.isAnswered;

  @override
  void initState() {
    super.initState();
    answerCtrl.text = widget.doubt.answerText ?? "";
  }

  @override
  void dispose() {
    answerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final doubt = widget.doubt;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Doubt Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= STUDENT INFO =================
            _infoRow(context, "Student", doubt.studentName),
            _infoRow(context, "Class", doubt.studentClass),

            const SizedBox(height: 14),

            // ================= SUBJECT / TOPIC =================
            _infoRow(context, "Subject", doubt.subject),
            _infoRow(context, "Topic", doubt.topic),

            const SizedBox(height: 20),

            // ================= QUESTION =================
            Text(
              "Question",
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),

            _contentBox(
              context,
              text: doubt.questionText.isNotEmpty
                  ? doubt.questionText
                  : "Question attached as a file.",
            ),

            const SizedBox(height: 10),

            if (doubt.questionFileUrl != null)
              TextButton.icon(
                onPressed: () {
                  AppNotifications.showInfo(
                    context,
                    "File will open in browser or download automatically.",
                  );
                },
                icon: const Icon(Icons.attach_file),
                label: const Text("View Question Attachment"),
              ),

            const SizedBox(height: 30),

            // ================= ANSWER =================
            Row(
              children: [
                Text(
                  "Your Answer",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                _StatusChip(isAnswered: isAnswered),
              ],
            ),
            const SizedBox(height: 6),

            if (isAnswered)
              _contentBox(
                context,
                text: (doubt.answerText != null &&
                        doubt.answerText!.isNotEmpty)
                    ? doubt.answerText!
                    : "Answer provided as an attachment.",
              )
            else ...[
              AppTextField(
                label: "Type your answer here",
                controller: answerCtrl,
                maxLines: 4,
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: pickAnswerFile,
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Upload Solution File"),
                  ),
                  const SizedBox(width: 12),
                  if (answerFile != null)
                    Expanded(
                      child: Text(
                        answerFile!.path.split('/').last,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 30),

              AppButton(
                label: "Submit Answer",
                isLoading: isLoading,
                onPressed:
                    isLoading ? null : () => _submitAnswer(doubt),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ================= LOGIC =================

  Future<void> _submitAnswer(DoubtModel doubt) async {
    if (isAnswered) {
      AppNotifications.showInfo(
        context,
        "This doubt has already been answered.",
      );
      return;
    }

    if (answerCtrl.text.trim().isEmpty && answerFile == null) {
      AppNotifications.showError(
        context,
        "Provide an answer or upload a file",
      );
      return;
    }

    setState(() => isLoading = true);
    AppNotifications.showLoading(
      context,
      message: "Submitting answer...",
    );

    try {
      String? fileUrl;

      if (answerFile != null) {
        fileUrl = await _storageService.uploadDoubtAnswerFile(
          file: answerFile!,
          teacherId: doubt.teacherId ?? "",
          doubtId: doubt.id,
        );
      }

      await _doubtRepo.answerDoubt(
        doubtId: doubt.id,
        answerText: answerCtrl.text.trim().isNotEmpty
            ? answerCtrl.text.trim()
            : null,
        answerFileUrl: fileUrl,
      );

      if (!mounted) return;
      AppNotifications.hideLoading(context);
      AppNotifications.showSuccess(
        context,
        "Answer submitted successfully",
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppNotifications.hideLoading(context);
      AppNotifications.showError(
        context,
        "Failed to submit answer",
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> pickAnswerFile() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => answerFile = File(picked.path));
    }
  }

  // ================= UI HELPERS =================

  Widget _infoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              "$label:",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : "-",
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contentBox(BuildContext context, {required String text}) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}

// =====================================================
// Status Chip (Theme Friendly)
// =====================================================
class _StatusChip extends StatelessWidget {
  final bool isAnswered;

  const _StatusChip({required this.isAnswered});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isAnswered
        ? Colors.green
        : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isAnswered ? "Answered" : "Pending",
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
