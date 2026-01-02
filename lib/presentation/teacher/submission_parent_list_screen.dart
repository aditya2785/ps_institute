import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'submissions_screen.dart';

class SubmissionParentListScreen extends StatelessWidget {
  final String type; // "assignment" or "homework"

  const SubmissionParentListScreen({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final collection =
        type == "assignment" ? "assignments" : "homework";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          type == "assignment"
              ? "Assignments"
              : "Homework",
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(collection)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Text(
                "No items found",
                style: theme.textTheme.bodyMedium,
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];

              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection("submissions")
                    .where("parentId", isEqualTo: doc.id)
                    .where("submissionType", isEqualTo: type)
                    .get(),
                builder: (context, snap) {
                  final count = snap.data?.docs.length ?? 0;

                  return ListTile(
                    title: Text(
                      doc["title"],
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      "Submitted by $count students",
                      style: theme.textTheme.bodyMedium,
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: theme.iconTheme.color,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SubmissionsScreen(
                            parentId: doc.id,
                            submissionType: type,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
