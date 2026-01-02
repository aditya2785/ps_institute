import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ps_institute/core/widgets/app_card.dart';
import 'package:ps_institute/core/widgets/loading_indicator.dart';
import 'package:ps_institute/data/models/submission_model.dart';

class SubmissionsScreen extends StatelessWidget {
  final String parentId;        // assignmentId or homeworkId
  final String submissionType;  // "assignment" or "homework"

  const SubmissionsScreen({
    super.key,
    required this.parentId,
    required this.submissionType,
  });

  // -------------------------------------------------------
  // SAFE URL LAUNCH FUNCTION
  // -------------------------------------------------------
  Future<void> openFile(String urlStr) async {
    final url = Uri.parse(urlStr);

    final ok = await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );

    if (!ok) {
      throw Exception("Could not launch $urlStr");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          submissionType == "assignment"
              ? "Assignment Submissions"
              : "Homework Submissions",
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("submissions")
            .where("parentId", isEqualTo: parentId)
            .where("submissionType", isEqualTo: submissionType)
            .orderBy("submittedAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LoadingIndicator();
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/empty_state.png",
                    height: 150,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No submissions yet.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium!.color!
                          .withOpacity(0.6),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          final submissions = docs
              .map(
                (d) => SubmissionModel.fromMap(
                  d.data() as Map<String, dynamic>,
                  d.id,
                ),
              )
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              final sub = submissions[index];

              return AppCard(
                margin: const EdgeInsets.only(bottom: 14),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      // ================= STUDENT IMAGE =================
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: colors.surfaceVariant,
                        backgroundImage: sub.studentImage != null
                            ? NetworkImage(sub.studentImage!)
                            : const AssetImage(
                                "assets/images/profile_default.png",
                              ) as ImageProvider,
                      ),

                      const SizedBox(width: 16),

                      // ================= SUBMISSION INFO =================
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sub.studentName,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Submitted: ${sub.submittedAt.toLocal().toString().split(' ')[0]}",
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 13,
                                color: theme.textTheme.bodySmall!.color!
                                    .withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ================= OPEN FILE BUTTON =================
                      IconButton(
                        icon: Icon(
                          Icons.open_in_new,
                          color: colors.primary,
                        ),
                        onPressed: () async {
                          try {
                            await openFile(sub.fileUrl);
                          } catch (_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Cannot open file"),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
