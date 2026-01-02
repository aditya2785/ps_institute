import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ps_institute/config/palette.dart';
import 'package:ps_institute/core/utils/formatters.dart';
import 'package:ps_institute/core/widgets/app_card.dart';
import 'package:ps_institute/data/models/assignment_model.dart';
import 'package:ps_institute/presentation/student/submit_assignment_screen.dart';

class AssignmentTile extends StatelessWidget {
  final AssignmentModel assignment;
  final VoidCallback? onTap;

  const AssignmentTile({
    super.key,
    required this.assignment,
    this.onTap,
  });

  Future<void> _openFile(BuildContext context) async {
    if (assignment.fileUrl == null || assignment.fileUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No file attached")),
      );
      return;
    }

    final uri = Uri.parse(assignment.fileUrl!);

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open file")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ======================
          // HEADER ROW
          // ======================
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Palette.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.assignment_rounded,
                  size: 28,
                  color: Palette.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      assignment.subject,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Due: ${Formatters.formatDate(assignment.dueDate)}",
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ======================
          // FILE BUTTON
          // ======================
          if (assignment.fileUrl != null &&
              assignment.fileUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _openFile(context),
              icon: const Icon(Icons.attach_file),
              label: const Text("View Attached File"),
            ),
          ],

          // ======================
          // SUBMIT BUTTON
          // ======================
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        SubmitAssignmentScreen(assignment: assignment),
                  ),
                );
              },
              icon: const Icon(Icons.send),
              label: const Text("Submit"),
            ),
          ),
        ],
      ),
    );
  }
}
