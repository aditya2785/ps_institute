import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? profileImage;
  final DateTime createdAt;
  final String? studentClass;
  final String? teacherSubject;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.createdAt,
    this.profileImage,
    this.studentClass,
    this.teacherSubject,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? '',
      profileImage: map['profileImage'],
      studentClass: map['studentClass'],
      teacherSubject: map['teacherSubject'],
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "email": email,
      "phone": phone,
      "role": role,
      "profileImage": profileImage,
      "studentClass": studentClass,
      "teacherSubject": teacherSubject,
      "createdAt": Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? role,
    String? profileImage,
    String? studentClass,
    String? teacherSubject,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      studentClass: studentClass ?? this.studentClass,
      teacherSubject: teacherSubject ?? this.teacherSubject,
      createdAt: createdAt,
    );
  }
}
