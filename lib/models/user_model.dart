import 'package:cloud_firestore/cloud_firestore.dart';

class StudentProfile {
  final String uid;
  final String fullName;
  final String email;
  final String academicProgram;
  final String bio;
  final List<String> skills;
  final String phoneNumber;
  final DateTime createdAt;

  StudentProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.academicProgram,
    required this.bio,
    required this.skills,
    required this.phoneNumber,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'academicProgram': academicProgram,
      'bio': bio,
      'skills': skills,
      'phoneNumber': phoneNumber,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory StudentProfile.fromMap(Map<String, dynamic> map) {
    return StudentProfile(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      academicProgram: map['academicProgram'] ?? '',
      bio: map['bio'] ?? '',
      skills: List<String>.from(map['skills'] ?? []),
      phoneNumber: map['phoneNumber'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class StartupProfile {
  final String uid;
  final String companyName;
  final String email;
  final String description;
  final String website;
  final String industry;
  final String rdbCertificateUrl;
  final String phoneNumber;
  final bool isVerified;
  final DateTime createdAt;

  StartupProfile({
    required this.uid,
    required this.companyName,
    required this.email,
    required this.description,
    required this.website,
    required this.industry,
    required this.rdbCertificateUrl,
    required this.phoneNumber,
    required this.isVerified,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'companyName': companyName,
      'email': email,
      'description': description,
      'website': website,
      'industry': industry,
      'rdbCertificateUrl': rdbCertificateUrl,
      'phoneNumber': phoneNumber,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory StartupProfile.fromMap(Map<String, dynamic> map) {
    return StartupProfile(
      uid: map['uid'] ?? '',
      companyName: map['companyName'] ?? '',
      email: map['email'] ?? '',
      description: map['description'] ?? '',
      website: map['website'] ?? '',
      industry: map['industry'] ?? '',
      rdbCertificateUrl: map['rdbCertificateUrl'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      isVerified: map['isVerified'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  StartupProfile copyWith({
    String? uid,
    String? companyName,
    String? email,
    String? description,
    String? website,
    String? industry,
    String? rdbCertificateUrl,
    String? phoneNumber,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return StartupProfile(
      uid: uid ?? this.uid,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      description: description ?? this.description,
      website: website ?? this.website,
      industry: industry ?? this.industry,
      rdbCertificateUrl: rdbCertificateUrl ?? this.rdbCertificateUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
