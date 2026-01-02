import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import 'package:ps_institute/core/utils/notifications.dart';
import 'package:ps_institute/core/widgets/app_button.dart';
import 'package:ps_institute/core/widgets/app_textfield.dart';

import 'package:ps_institute/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ps_institute/presentation/viewmodels/notes_viewmodel.dart';

class UploadNoteScreen extends StatefulWidget {
  const UploadNoteScreen({super.key});

  @override
  State<UploadNoteScreen> createState() => _UploadNoteScreenState();
}

class _UploadNoteScreenState extends State<UploadNoteScreen> {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  String? selectedClass;
  String? selectedSubject;

  File? selectedFile;
  bool isUploading = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Notes")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppTextField(
              label: "Notes Title",
              controller: titleCtrl,
            ),
            const SizedBox(height: 10),

            AppTextField(
              label: "Description",
              controller: descCtrl,
              maxLines: 4,
            ),
            const SizedBox(height: 20),

            _dropdown(
              label: "Subject",
              value: selectedSubject,
              items: subjects,
              onChange: (v) => setState(() => selectedSubject = v),
            ),
            const SizedBox(height: 20),

            _dropdown(
              label: "Class",
              value: selectedClass,
              items: classes,
              onChange: (v) => setState(() => selectedClass = v),
            ),
            const SizedBox(height: 20),

            GestureDetector(
              onTap: pickFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.upload_file, size: 26),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedFile != null
                            ? selectedFile!.path.split('/').last
                            : "Upload Notes File (PDF/Image/Doc)",
                        style: TextStyle(
                          fontSize: 15,
                          color: selectedFile != null
                              ? Colors.black
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            AppButton(
              label: "Upload Notes",
              isLoading: isUploading,
              onPressed: uploadNotes,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- FILE PICK ----------------
  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  // ---------------- UPLOAD NOTES ----------------
  Future<void> uploadNotes() async {
    if (titleCtrl.text.trim().isEmpty ||
        descCtrl.text.trim().isEmpty ||
        selectedClass == null ||
        selectedSubject == null ||
        selectedFile == null) {
      AppNotifications.showError(context, "Please fill all fields");
      return;
    }

    final authVm = context.read<AuthViewModel>();
    final notesVm = context.read<NotesViewModel>();
    final teacher = authVm.currentUser!;
    final teacherSubject = teacher.teacherSubject?.trim();

    // 🚫 SUBJECT NOT SET IN PROFILE
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
        "You can only upload notes for your subject: $teacherSubject",
      );
      return;
    }

    setState(() => isUploading = true);

    try {
      final error = await notesVm.uploadNotes(
        title: titleCtrl.text.trim(),
        description: descCtrl.text.trim(),
        subject: selectedSubject!,
        className: selectedClass!,
        teacherId: teacher.uid,
        teacherName: teacher.name,
        file: selectedFile!,
      );

      if (error != null) {
        AppNotifications.showError(context, error);
        return;
      }

      AppNotifications.showSuccess(context, "Notes Uploaded!");
      Navigator.pop(context);
    } catch (e) {
      AppNotifications.showError(context, e.toString());
    } finally {
      setState(() => isUploading = false);
    }
  }

  // ---------------- DROPDOWN ----------------
  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChange,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text("Select $label"),
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
        ),
      ],
    );
  }
}
