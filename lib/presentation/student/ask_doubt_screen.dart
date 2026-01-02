import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:ps_institute/core/widgets/app_button.dart';
import 'package:ps_institute/core/widgets/app_textfield.dart';
import 'package:ps_institute/core/utils/notifications.dart';

import 'package:ps_institute/data/models/user_model.dart';
import 'package:ps_institute/data/models/doubt_model.dart';
import 'package:ps_institute/data/repositories/user_repo.dart';
import 'package:ps_institute/data/repositories/doubt_repo.dart';
import 'package:ps_institute/data/services/storage_service.dart';

import 'package:ps_institute/presentation/viewmodels/auth_viewmodel.dart';

class AskDoubtScreen extends StatefulWidget {
  const AskDoubtScreen({super.key});

  @override
  State<AskDoubtScreen> createState() => _AskDoubtScreenState();
}

class _AskDoubtScreenState extends State<AskDoubtScreen> {
  final TextEditingController topicCtrl = TextEditingController();
  final TextEditingController questionCtrl = TextEditingController();

  final UserRepository _userRepo = UserRepository();
  final DoubtRepository _doubtRepo = DoubtRepository();

  List<UserModel> teachers = [];
  UserModel? selectedTeacher;

  File? questionFile;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    final list = await _userRepo.getAllTeachers();
    if (!mounted) return;
    setState(() => teachers = list);
  }

  @override
  void dispose() {
    topicCtrl.dispose();
    questionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final student = authVm.currentUser;

    if (student == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Ask a Doubt")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= TEACHER DROPDOWN =================
            const Text(
              "Select Teacher",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),

            DropdownButtonFormField<UserModel>(
              value: selectedTeacher,
              hint: const Text("Choose a teacher"),
              items: teachers
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(
                        "${t.name} (${t.teacherSubject ?? 'Subject'})",
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => selectedTeacher = v),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),

            // ================= SUBJECT (AUTO / READ-ONLY) =================
            IgnorePointer(
              ignoring: true,
              child: AppTextField(
                label: "Subject",
                controller: TextEditingController(
                  text: selectedTeacher?.teacherSubject ?? "",
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ================= TOPIC =================
            AppTextField(
              label: "Topic / Chapter",
              controller: topicCtrl,
            ),

            const SizedBox(height: 14),

            // ================= QUESTION =================
            AppTextField(
              label: "Your Question",
              controller: questionCtrl,
              maxLines: 4,
            ),

            const SizedBox(height: 14),

            // ================= FILE PICK =================
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: pickFile,
                  icon: const Icon(Icons.attach_file),
                  label: const Text("Attach File"),
                ),
                const SizedBox(width: 12),
                if (questionFile != null)
                  Expanded(
                    child: Text(
                      questionFile!.path.split('/').last,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 30),

            // ================= SUBMIT =================
            AppButton(
              label: "Submit Doubt",
              isLoading: isLoading,
              onPressed:
                  isLoading ? null : () => _submitDoubt(student),
            ),
          ],
        ),
      ),
    );
  }

  // ================= LOGIC =================

  Future<void> _submitDoubt(UserModel student) async {
    if (selectedTeacher == null) {
      AppNotifications.showError(context, "Please select a teacher");
      return;
    }

    if (topicCtrl.text.trim().isEmpty) {
      AppNotifications.showError(context, "Enter topic or chapter");
      return;
    }

    if (questionCtrl.text.trim().isEmpty &&
        questionFile == null) {
      AppNotifications.showError(
          context, "Enter question or attach a file");
      return;
    }

    setState(() => isLoading = true);
    AppNotifications.showLoading(context, message: "Submitting doubt...");

    try {
      String? fileUrl;

      if (questionFile != null) {
        fileUrl = await StorageService().uploadDoubtFile(
          questionFile!,
          student.uid,
        );
      }

      final doubt = DoubtModel(
        id: "",
        studentId: student.uid,
        studentName: student.name,
        studentClass: student.studentClass ?? "",
        teacherId: selectedTeacher!.uid,
        teacherName: selectedTeacher!.name,
        subject: selectedTeacher!.teacherSubject ?? "",
        topic: topicCtrl.text.trim(),
        questionText: questionCtrl.text.trim(),
        questionFileUrl: fileUrl,
        answerText: null,
        answerFileUrl: null,
        status: "pending",
        createdAt: DateTime.now(),
        answeredAt: null,
      );

      await _doubtRepo.createDoubt(doubt);

      if (!mounted) return;
      AppNotifications.hideLoading(context);
      AppNotifications.showSuccess(
          context, "Doubt submitted successfully");
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppNotifications.hideLoading(context);
      AppNotifications.showError(context, "Failed to submit doubt");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> pickFile() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => questionFile = File(picked.path));
    }
  }
}
