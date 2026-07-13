import 'package:equatable/equatable.dart';
import '../../models/notification_model.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {
  final String studentId;

  const LoadNotifications(this.studentId);

  @override
  List<Object> get props => [studentId];
}

class MarkNotificationAsRead extends NotificationEvent {
  final String notificationId;

  const MarkNotificationAsRead(this.notificationId);

  @override
  List<Object> get props => [notificationId];
}

class NotificationsUpdated extends NotificationEvent {
  final List<NotificationModel> notifications;

  const NotificationsUpdated(this.notifications);

  @override
  List<Object> get props => [notifications];
}
