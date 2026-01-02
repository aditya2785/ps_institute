import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ps_institute/core/widgets/loading_indicator.dart';
import 'package:ps_institute/data/models/doubt_model.dart';
import 'package:ps_institute/data/repositories/doubt_repo.dart';
import 'package:ps_institute/presentation/teacher/doubt_detail_teacher_screen.dart';
import 'package:ps_institute/presentation/viewmodels/auth_viewmodel.dart';

class TeacherNewDoubtsScreen extends StatelessWidget {
  const TeacherNewDoubtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final teacher = authVm.currentUser;

    if (teacher == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("New Doubts")),
      body: StreamBuilder<List<DoubtModel>>(
        stream:
            DoubtRepository().listenToTeacherDoubts(teacher.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const LoadingIndicator();
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No new doubts 🎉",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final pendingDoubts = snapshot.data!
              .where((d) => d.isPending)
              .toList();

          if (pendingDoubts.isEmpty) {
            return const Center(
              child: Text(
                "No pending doubts 🎉",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: pendingDoubts.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final doubt = pendingDoubts[index];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    doubt.studentName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text("Class: ${doubt.studentClass}"),
                      Text("Subject: ${doubt.subject}"),
                      Text("Topic: ${doubt.topic}"),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DoubtDetailTeacherScreen(
                          doubt: doubt,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
