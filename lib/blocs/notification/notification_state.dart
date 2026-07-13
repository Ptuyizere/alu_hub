import 'package:equatable/equatable.dart';
import '../../models/notification_model.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationsLoaded extends NotificationState {
  final List<NotificationModel> notifications;

  const NotificationsLoaded(this.notifications);

  @override
  List<Object> get props => [notifications];
}

class NotificationFailure extends NotificationState {
  final String errorMessage;

  const NotificationFailure(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
