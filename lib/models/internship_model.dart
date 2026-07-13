import 'package:cloud_firestore/cloud_firestore.dart';

class InternshipModel {
  final String id;
  final String startupId;
  final String startupName;
  final String title;
  final String roleType;
  final String description;
  final String requirements;
  final String locationType; 
  final String compensationType;
  final String salaryRange;
  final DateTime createdAt;
  final bool isActive;

  InternshipModel({
    required this.id,
    required this.startupId,
    required this.startupName,
    required this.title,
    required this.roleType,
    required this.description,
    required this.requirements,
    required this.locationType,
    required this.compensationType,
    required this.salaryRange,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startupId': startupId,
      'startupName': startupName,
      'title': title,
      'roleType': roleType,
      'description': description,
      'requirements': requirements,
      'locationType': locationType,
      'compensationType': compensationType,
      'salaryRange': salaryRange,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }

  factory InternshipModel.fromMap(Map<String, dynamic> map, String documentId) {
    return InternshipModel(
      id: documentId,
      startupId: map['startupId'] ?? '',
      startupName: map['startupName'] ?? '',
      title: map['title'] ?? '',
      roleType: map['roleType'] ?? '',
      description: map['description'] ?? '',
      requirements: map['requirements'] ?? '',
      locationType: map['locationType'] ?? '',
      compensationType: map['compensationType'] ?? '',
      salaryRange: map['salaryRange'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }

  InternshipModel copyWith({
    String? id,
    String? startupId,
    String? startupName,
    String? title,
    String? roleType,
    String? description,
    String? requirements,
    String? locationType,
    String? compensationType,
    String? salaryRange,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return InternshipModel(
      id: id ?? this.id,
      startupId: startupId ?? this.startupId,
      startupName: startupName ?? this.startupName,
      title: title ?? this.title,
      roleType: roleType ?? this.roleType,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      locationType: locationType ?? this.locationType,
      compensationType: compensationType ?? this.compensationType,
      salaryRange: salaryRange ?? this.salaryRange,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
