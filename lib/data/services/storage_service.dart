import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class StorageService {
  // ---------------------------------------------------------
  // 🔐 Cloudinary Config (SAFE TO KEEP IN FRONTEND)
  // ---------------------------------------------------------
  static const String _cloudName = "ddlch12oc";
  static const String _uploadPreset = "ps_institute_unsigned";

  // ---------------------------------------------------------
  // 📤 Internal Upload Helper
  // ---------------------------------------------------------
  Future<String> _uploadToCloudinary({
    required File file,
    required String folder,
  }) async {
    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$_cloudName/auto/upload",
    );

    final request = http.MultipartRequest("POST", uri)
      ..fields["upload_preset"] = _uploadPreset
      ..fields["folder"] = folder
      ..files.add(
        await http.MultipartFile.fromPath("file", file.path),
      );

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Cloudinary upload failed: $responseData");
    }

    final decoded = json.decode(responseData);
    return decoded["secure_url"];
  }

  // ---------------------------------------------------------
  // Upload File (PDF, Image, DOC, etc.)
  // ---------------------------------------------------------
  Future<String> uploadFile({
    required String folder,
    required File file,
    required String uid,
  }) async {
    return _uploadToCloudinary(
      file: file,
      folder: "$folder/$uid",
    );
  }

  // ---------------------------------------------------------
  // Upload Profile Image
  // ---------------------------------------------------------
  Future<String> uploadProfileImage(File file, String uid) async {
    return _uploadToCloudinary(
      file: file,
      folder: "profile_images/$uid",
    );
  }

  // ---------------------------------------------------------
  // Upload Doubt Question File
  // ---------------------------------------------------------
  Future<String> uploadDoubtFile(File file, String uid) async {
    return _uploadToCloudinary(
      file: file,
      folder: "doubts/questions/$uid",
    );
  }

  // ---------------------------------------------------------
  // Upload Doubt Answer File (Teacher)
  // ---------------------------------------------------------
  Future<String> uploadDoubtAnswerFile({
    required File file,
    required String teacherId,
    required String doubtId,
  }) async {
    return _uploadToCloudinary(
      file: file,
      folder: "doubts/answers/$doubtId/$teacherId",
    );
  }

  // ---------------------------------------------------------
  // Upload Submission (Homework / Assignment)
  // ---------------------------------------------------------
  Future<String> uploadSubmission({
    required File file,
    required String uid,
    required String parentId,
  }) async {
    return _uploadToCloudinary(
      file: file,
      folder: "submissions/$parentId/$uid",
    );
  }

  // ---------------------------------------------------------
  // Delete File (NO-OP for Cloudinary Free Tier)
  // ---------------------------------------------------------
  Future<void> deleteFile(String url) async {
    // Cloudinary free-tier frontend deletes are NOT supported
    // Safe no-op to keep app logic intact
    return;
  }
}
