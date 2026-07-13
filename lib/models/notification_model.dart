import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String recipientId;
  final String senderId;
  final String title;
  final String message;
  final String startupContactEmail;
  final String startupContactPhone;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.recipientId,
    required this.senderId,
    required this.title,
    required this.message,
    required this.startupContactEmail,
    required this.startupContactPhone,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipientId': recipientId,
      'senderId': senderId,
      'title': title,
      'message': message,
      'startupContactEmail': startupContactEmail,
      'startupContactPhone': startupContactPhone,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, String documentId) {
    return NotificationModel(
      id: documentId,
      recipientId: map['recipientId'] ?? '',
      senderId: map['senderId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      startupContactEmail: map['startupContactEmail'] ?? '',
      startupContactPhone: map['startupContactPhone'] ?? '',
      isRead: map['isRead'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  NotificationModel copyWith({
    String? id,
    String? recipientId,
    String? senderId,
    String? title,
    String? message,
    String? startupContactEmail,
    String? startupContactPhone,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      senderId: senderId ?? this.senderId,
      title: title ?? this.title,
      message: message ?? this.message,
      startupContactEmail: startupContactEmail ?? this.startupContactEmail,
      startupContactPhone: startupContactPhone ?? this.startupContactPhone,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
