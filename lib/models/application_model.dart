import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationModel {
  final String id;
  final String internshipId;
  final String studentId;
  final String startupId;
  final String studentName;
  final String studentEmail;
  final String studentProgram;
  final String internshipTitle;
  final String coverLetter;
  final String status;
  final DateTime createdAt;

  ApplicationModel({
    required this.id,
    required this.internshipId,
    required this.studentId,
    required this.startupId,
    required this.studentName,
    required this.studentEmail,
    required this.studentProgram,
    required this.internshipTitle,
    required this.coverLetter,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'internshipId': internshipId,
      'studentId': studentId,
      'startupId': startupId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'studentProgram': studentProgram,
      'internshipTitle': internshipTitle,
      'coverLetter': coverLetter,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ApplicationModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ApplicationModel(
      id: documentId,
      internshipId: map['internshipId'] ?? '',
      studentId: map['studentId'] ?? '',
      startupId: map['startupId'] ?? '',
      studentName: map['studentName'] ?? '',
      studentEmail: map['studentEmail'] ?? '',
      studentProgram: map['studentProgram'] ?? '',
      internshipTitle: map['internshipTitle'] ?? '',
      coverLetter: map['coverLetter'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  ApplicationModel copyWith({
    String? id,
    String? internshipId,
    String? studentId,
    String? startupId,
    String? studentName,
    String? studentEmail,
    String? studentProgram,
    String? internshipTitle,
    String? coverLetter,
    String? status,
    DateTime? createdAt,
  }) {
    return ApplicationModel(
      id: id ?? this.id,
      internshipId: internshipId ?? this.internshipId,
      studentId: studentId ?? this.studentId,
      startupId: startupId ?? this.startupId,
      studentName: studentName ?? this.studentName,
      studentEmail: studentEmail ?? this.studentEmail,
      studentProgram: studentProgram ?? this.studentProgram,
      internshipTitle: internshipTitle ?? this.internshipTitle,
      coverLetter: coverLetter ?? this.coverLetter,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
