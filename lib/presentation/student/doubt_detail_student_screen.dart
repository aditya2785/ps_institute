import 'package:flutter/material.dart';

import 'package:ps_institute/core/widgets/app_button.dart';
import 'package:ps_institute/core/utils/notifications.dart';

import 'package:ps_institute/data/models/doubt_model.dart';

class DoubtDetailStudentScreen extends StatelessWidget {
  final DoubtModel doubt;

  const DoubtDetailStudentScreen({
    super.key,
    required this.doubt,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAnswered = doubt.isAnswered;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Doubt Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= TEACHER INFO =================
            _infoRow("Teacher", doubt.teacherName ?? "Not assigned"),
            _infoRow("Subject", doubt.subject),
            _infoRow("Topic", doubt.topic),

            const SizedBox(height: 20),

            // ================= QUESTION =================
            const Text(
              "Your Question",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),

            _contentBox(
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
                const Text(
                  "Teacher’s Answer",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                _StatusChip(isAnswered: isAnswered),
              ],
            ),

            const SizedBox(height: 6),

            if (!isAnswered)
              _pendingBox()
            else ...[
              _contentBox(
                text: (doubt.answerText != null &&
                        doubt.answerText!.isNotEmpty)
                    ? doubt.answerText!
                    : "Answer provided as an attachment.",
              ),
              const SizedBox(height: 10),
              if (doubt.answerFileUrl != null)
                TextButton.icon(
                  onPressed: () {
                    AppNotifications.showInfo(
                      context,
                      "File will open in browser or download automatically.",
                    );
                  },
                  icon: const Icon(Icons.download),
                  label: const Text("Download Solution File"),
                ),
            ],

            const SizedBox(height: 30),

            // ================= ACTION =================
            AppButton(
              label: "Back",
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : "-",
            ),
          ),
        ],
      ),
    );
  }

  Widget _contentBox({required String text}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text),
    );
  }

  Widget _pendingBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        "⏳ Your doubt is still pending.\nThe teacher will respond soon.",
        style: TextStyle(color: Colors.orange),
      ),
    );
  }
}

// =====================================================
// Status Chip
// =====================================================
class _StatusChip extends StatelessWidget {
  final bool isAnswered;

  const _StatusChip({required this.isAnswered});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAnswered
            ? Colors.green.withOpacity(0.15)
            : Colors.orange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isAnswered ? "Answered" : "Pending",
        style: TextStyle(
          color: isAnswered ? Colors.green : Colors.orange,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
