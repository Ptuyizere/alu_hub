import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _notificationRepository;
  StreamSubscription? _notificationSubscription;

  NotificationBloc({required NotificationRepository notificationRepository})
      : _notificationRepository = notificationRepository,
        super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<NotificationsUpdated>(_onNotificationsUpdated);
  }

  void _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) {
    emit(NotificationLoading());
    _notificationSubscription?.cancel();
    _notificationSubscription = _notificationRepository
        .getNotifications(event.studentId)
        .listen((notifications) {
      add(NotificationsUpdated(notifications));
    });
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _notificationRepository.markAsRead(event.notificationId);
    } catch (e) {
      emit(NotificationFailure(e.toString()));
    }
  }

  void _onNotificationsUpdated(
    NotificationsUpdated event,
    Emitter<NotificationState> emit,
  ) {
    emit(NotificationsLoaded(event.notifications));
  }

  @override
  Future<void> close() {
    _notificationSubscription?.cancel();
    return super.close();
  }
}
