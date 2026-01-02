import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import 'package:ps_institute/core/utils/notifications.dart';
import 'package:ps_institute/core/widgets/app_button.dart';
import 'package:ps_institute/core/widgets/app_textfield.dart';

import 'package:ps_institute/data/models/homework_model.dart';
import 'package:ps_institute/data/repositories/homework_repo.dart';
import 'package:ps_institute/presentation/viewmodels/homework_viewmodel.dart';

import 'package:ps_institute/data/services/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ps_institute/presentation/viewmodels/auth_viewmodel.dart';

class AddHomeworkScreen extends StatefulWidget {
  const AddHomeworkScreen({super.key});

  @override
  State<AddHomeworkScreen> createState() => _AddHomeworkScreenState();
}

class _AddHomeworkScreenState extends State<AddHomeworkScreen> {
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
        title: const Text("Add Homework"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ---------------------------------------------------
            // TITLE FIELD
            // ---------------------------------------------------
            AppTextField(
              label: "Homework Title",
              controller: titleCtrl,
            ),
            const SizedBox(height: 10),

            // ---------------------------------------------------
            // DESCRIPTION FIELD
            // ---------------------------------------------------
            AppTextField(
              label: "Description",
              controller: descCtrl,
              maxLines: 4,
            ),
            const SizedBox(height: 20),

            // ---------------------------------------------------
            // SUBJECT DROPDOWN
            // ---------------------------------------------------
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

            

            // ---------------------------------------------------
            // CLASS DROPDOWN
            // ---------------------------------------------------
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

            // ---------------------------------------------------
            // DUE DATE PICKER
            // ---------------------------------------------------
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
                    Icon(
                      Icons.calendar_today,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      selectedDueDate == null
                          ? "Select Due Date"
                          : selectedDueDate!
                              .toLocal()
                              .toString()
                              .split(" ")[0],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 15,
                        color: selectedDueDate == null
                            ? theme.colorScheme.onSurface.withOpacity(0.6)
                            : theme.colorScheme.onSurface,
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ---------------------------------------------------
            // FILE PICKER
            // ---------------------------------------------------
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
                    Icon(
                      Icons.upload_file,
                      size: 26,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedFile != null
                            ? selectedFile!.path.split('/').last
                            : "Upload File (PDF/Image/Doc)",
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

            const SizedBox(height: 40),

            // ---------------------------------------------------
            // SUBMIT BUTTON
            // ---------------------------------------------------
            AppButton(
              label: "Create Homework",
              isLoading: isUploading,
              onPressed: createHomework,
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // PICK FILE
  // -------------------------------------------------------------------
  Future<void> pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  // -------------------------------------------------------------------
  // PICK DUE DATE
  // -------------------------------------------------------------------
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

  // -------------------------------------------------------------------
  // CREATE HOMEWORK
  // -------------------------------------------------------------------
Future<void> createHomework() async {
  if (titleCtrl.text.trim().isEmpty ||
      descCtrl.text.trim().isEmpty ||
      selectedClass == null ||
      selectedSubject == null ||
      selectedDueDate == null ||
      selectedFile == null) {
    AppNotifications.showError(context, "Please fill all fields");
    return;
  }

  final authVm = context.read<AuthViewModel>();
  final homeworkVm = context.read<HomeworkViewModel>();
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
      "You can only add homework for your subject: $teacherSubject",
    );
    return;
  }

  setState(() => isUploading = true);

  try {
    final error = await homeworkVm.createHomework(
      title: titleCtrl.text.trim(),
      description: descCtrl.text.trim(),
      subject: selectedSubject!,
      className: selectedClass!,
      dueDate: selectedDueDate!,
      teacherId: teacher.uid,
      teacherName: teacher.name,
      file: selectedFile!,
    );

    if (error != null) {
      AppNotifications.showError(context, error);
      return;
    }

    AppNotifications.showSuccess(context, "Homework Created!");
    Navigator.pop(context);
  } catch (e) {
    AppNotifications.showError(context, e.toString());
  } finally {
    setState(() => isUploading = false);
  }
}


  // -------------------------------------------------------------------
  // DROPDOWN WIDGET
  // -------------------------------------------------------------------
  Widget _dropdown(
    BuildContext context, {
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChange,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint),
          dropdownColor: theme.colorScheme.surface,
          items: items.map((v) {
            return DropdownMenuItem(
              value: v,
              child: Text(v),
            );
          }).toList(),
          onChanged: onChange,
        ),
      ),
    );
  }
}
