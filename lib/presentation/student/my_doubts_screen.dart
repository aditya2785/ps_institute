import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ps_institute/core/widgets/loading_indicator.dart';

import 'package:ps_institute/data/models/doubt_model.dart';
import 'package:ps_institute/data/repositories/doubt_repo.dart';

import 'package:ps_institute/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ps_institute/presentation/student/doubt_detail_student_screen.dart';

class MyDoubtsScreen extends StatelessWidget {
  const MyDoubtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final student = authVm.currentUser;

    if (student == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final DoubtRepository doubtRepo = DoubtRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Doubts"),
      ),
      body: StreamBuilder<List<DoubtModel>>(
        stream: doubtRepo.listenToStudentDoubts(student.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "You haven’t asked any doubts yet 🤔",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final doubts = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: doubts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doubt = doubts[index];
              return _MyDoubtTile(doubt: doubt);
            },
          );
        },
      ),
    );
  }
}

// =====================================================
// Student Doubt Tile
// =====================================================
class _MyDoubtTile extends StatelessWidget {
  final DoubtModel doubt;

  const _MyDoubtTile({required this.doubt});

  @override
  Widget build(BuildContext context) {
    final bool isAnswered = doubt.isAnswered;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                DoubtDetailStudentScreen(doubt: doubt),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Theme.of(context)
              .colorScheme
              .surfaceVariant
              .withOpacity(0.4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- SUBJECT + STATUS ----------------
            Row(
              children: [
                Text(
                  doubt.subject,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                _StatusChip(isAnswered: isAnswered),
              ],
            ),

            const SizedBox(height: 6),

            // ---------------- TOPIC ----------------
            Text(
              doubt.topic,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 10),

            // ---------------- QUESTION PREVIEW ----------------
            Text(
              doubt.questionText.isNotEmpty
                  ? doubt.questionText
                  : "📎 File attached",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
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
