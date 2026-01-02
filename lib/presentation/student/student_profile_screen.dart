import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:ps_institute/core/widgets/app_button.dart';
import 'package:ps_institute/core/widgets/app_textfield.dart';
import 'package:ps_institute/core/utils/notifications.dart';
import 'package:ps_institute/core/utils/validators.dart';

import 'package:ps_institute/data/models/user_model.dart';
import 'package:ps_institute/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ps_institute/presentation/viewmodels/user_viewmodel.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final TextEditingController nameCtrl = TextEditingController();
  String? selectedClass;
  File? profileImage;

  final List<String> classes = const [
    "Class 6",
    "Class 7",
    "Class 8",
    "Class 9",
    "Class 10",
    "Class 11",
    "Class 12",
  ];

  @override
  void initState() {
    super.initState();
    final user =
        Provider.of<AuthViewModel>(context, listen: false).currentUser;
    if (user != null) {
      nameCtrl.text = user.name;
      selectedClass = user.studentClass;
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final userVm = context.watch<UserViewModel>();
    final user = authVm.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ================= PROFILE IMAGE =================
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundImage: profileImage != null
                        ? FileImage(profileImage!)
                        : (user.profileImage != null
                            ? NetworkImage(user.profileImage!)
                            : const AssetImage(
                                "assets/images/profile_default.png",
                              ) as ImageProvider),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ================= NAME =================
            AppTextField(
              label: "Full Name",
              controller: nameCtrl,
              validator: Validators.name,
            ),

            const SizedBox(height: 14),

            // ================= CLASS =================
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Class",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 6),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedClass,
                  hint: const Text("Select Class"),
                  isExpanded: true,
                  items: classes
                      .map(
                        (cls) => DropdownMenuItem(
                          value: cls,
                          child: Text(cls),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => selectedClass = v),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ================= SAVE =================
            AppButton(
              label: "Save Changes",
              isLoading: userVm.isLoading,
              onPressed: userVm.isLoading
                  ? null
                  : () => _saveProfile(context, user),
            ),

            const SizedBox(height: 30),

            // ================= LOGOUT =================
            AppButton(
              label: "Logout",
              onPressed: () => _confirmLogout(authVm),
              borderRadius: 10,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ================= LOGIC =================

Future<void> _saveProfile(BuildContext context, UserModel user) async {
  if (nameCtrl.text.trim().length < 3) {
    AppNotifications.showError(context, "Enter a valid name");
    return;
  }

  if (selectedClass == null) {
    AppNotifications.showError(context, "Please select your class");
    return;
  }

  AppNotifications.showLoading(context, message: "Updating profile...");

  try {
    // Update basic fields
    await context.read<UserViewModel>().updateUser(
      user.uid,
      {
        "name": nameCtrl.text.trim(),
        "studentClass": selectedClass,
      },
    );

    // Update profile image separately if changed
    if (profileImage != null) {
      await context
          .read<UserViewModel>()
          .updateProfileImage(user.uid, profileImage);
    }

    // 🔥🔥🔥 THIS WAS MISSING 🔥🔥🔥
    await context.read<AuthViewModel>().refreshUser();

    if (!mounted) return;
    AppNotifications.hideLoading(context);
    AppNotifications.showSuccess(context, "Profile updated successfully");
  } catch (e) {
    debugPrint("PROFILE UPDATE ERROR: $e");
    if (!mounted) return;
    AppNotifications.hideLoading(context);
    AppNotifications.showError(context, "Failed to update profile");
  }
}


  Future<void> _confirmLogout(AuthViewModel authVm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await authVm.logout(context);
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // 🔥 faster upload
    );

    if (picked != null) {
      setState(() => profileImage = File(picked.path));
    }
  }
}
