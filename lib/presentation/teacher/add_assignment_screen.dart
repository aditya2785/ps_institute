import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import 'package:ps_institute/core/utils/notifications.dart';
import 'package:ps_institute/core/widgets/app_button.dart';
import 'package:ps_institute/core/widgets/app_textfield.dart';

import 'package:ps_institute/presentation/viewmodels/assignment_viewmodel.dart';
import 'package:ps_institute/presentation/viewmodels/auth_viewmodel.dart';

class AddAssignmentScreen extends StatefulWidget {
  const AddAssignmentScreen({super.key});

  @override
  State<AddAssignmentScreen> createState() => _AddAssignmentScreenState();
}

class _AddAssignmentScreenState extends State<AddAssignmentScreen> {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  String? selectedClass;
  String? selectedSubject;
  DateTime? selectedDueDate;

  final List<String> classes = [
    "Class 6",
    "Class 7",
    "Class 8",
    "Class 9",
    "Class 10",
    "Class 11",
    "Class 12",
  ];

  final List<String> subjects = [
    "Math",
    "Science",
    "English",
    "Hindi",
    "Physics",
    "Chemistry",
    "Biology",
    "Computer",
    "History",
    "Geography",
  ];

  File? selectedFile;
  bool isUploading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Assignment"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppTextField(
              label: "Assignment Title",
              controller: titleCtrl,
            ),
            const SizedBox(height: 10),

            AppTextField(
              label: "Description",
              controller: descCtrl,
              maxLines: 4,
            ),
            const SizedBox(height: 20),

            // ---------------- SUBJECT ----------------
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Subject",
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 6),

            _dropdown(
              context,
              value: selectedSubject,
              hint: "Select Subject",
              items: subjects,
              onChange: (v) => setState(() => selectedSubject = v),
            ),
            const SizedBox(height: 20),

            // ---------------- CLASS ----------------
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Class",
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 6),

            _dropdown(
              context,
              value: selectedClass,
              hint: "Select Class",
              items: classes,
              onChange: (v) => setState(() => selectedClass = v),
            ),
            const SizedBox(height: 20),

            // ---------------- DUE DATE ----------------
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Due Date",
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 6),

            GestureDetector(
              onTap: pickDueDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: 10),
                    Text(
                      selectedDueDate == null
                          ? "Select Due Date"
                          : selectedDueDate!
                              .toLocal()
                              .toString()
                              .split(" ")[0],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ---------------- FILE PICK ----------------
            GestureDetector(
              onTap: pickFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.upload_file,
                        size: 26,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedFile != null
                            ? selectedFile!.path.split('/').last
                            : "Upload File (PDF/Image/Doc)",
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // ---------------- SUBMIT ----------------
            AppButton(
              label: "Create Assignment",
              isLoading: isUploading,
              onPressed: createAssignment,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickFile() async {
    final result =
        await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      initialDate: now,
    );

    if (picked != null) {
      setState(() {
        selectedDueDate = picked;
      });
    }
  }

  // ---------------------------------------------------
  // ✅ SAME FLOW AS HOMEWORK
  // UI → ViewModel → Repository
  // ---------------------------------------------------
  Future<void> createAssignment() async {
    if (titleCtrl.text.trim().isEmpty ||
        descCtrl.text.trim().isEmpty ||
        selectedClass == null ||
        selectedSubject == null ||
        selectedDueDate == null ||
        selectedFile == null) {
      AppNotifications.showError(context, "Please fill all fields");
      return;
    }

    setState(() => isUploading = true);

    try {
      final authVm = context.read<AuthViewModel>();
      final assignmentVm = context.read<AssignmentViewModel>();
      final teacher = authVm.currentUser!;
      final teacherSubject = teacher.teacherSubject?.trim();

// 🚫 SUBJECT NOT SET
if (teacherSubject == null || teacherSubject.isEmpty) {
  AppNotifications.showError(
    context,
    "Your profile subject is not set. Please update your profile first.",
  );
  return;
}

// 🚫 SUBJECT MISMATCH
if (selectedSubject!.trim() != teacherSubject) {
  AppNotifications.showError(
    context,
    "You can only add assignments for your subject: $teacherSubject",
  );
  return;
}


      final error = await assignmentVm.createAssignment(
        title: titleCtrl.text.trim(),
        description: descCtrl.text.trim(),
        subject: selectedSubject!,
        className: selectedClass!, // ✅ SAME AS HOMEWORK
        dueDate: selectedDueDate!,
        teacherId: teacher.uid,
        teacherName: teacher.name,
        file: selectedFile!,
      );

      if (error != null) {
        AppNotifications.showError(context, error);
        return;
      }

      AppNotifications.showSuccess(context, "Assignment Created!");
      Navigator.pop(context);
    } catch (e) {
      AppNotifications.showError(context, e.toString());
    } finally {
      setState(() => isUploading = false);
    }
  }

  Widget _dropdown(
    BuildContext context, {
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChange,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint),
          items: items
              .map(
                (v) => DropdownMenuItem(
                  value: v,
                  child: Text(v),
                ),
              )
              .toList(),
          onChanged: onChange,
        ),
      ),
    );
  }
}
