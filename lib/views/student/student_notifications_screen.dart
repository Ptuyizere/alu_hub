import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/app_constants.dart';
import '../../models/notification_model.dart';
import '../../blocs/notification/notification_bloc.dart';
import '../../blocs/notification/notification_event.dart';
import '../../blocs/notification/notification_state.dart';

class StudentNotificationsScreen extends StatefulWidget {
  final String studentId;

  const StudentNotificationsScreen({super.key, required this.studentId});

  @override
  State<StudentNotificationsScreen> createState() => _StudentNotificationsScreenState();
}

class _StudentNotificationsScreenState extends State<StudentNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(LoadNotifications(widget.studentId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppConstants.cardColor,
        foregroundColor: AppConstants.textPrimaryColor,
        elevation: 1.0,
      ),
      body: SafeArea(
        child: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off_outlined, color: AppConstants.textSecondaryColor, size: 64.0),
                    const SizedBox(height: 16.0),
                    Text(
                      'Your inbox is empty',
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamily,
                        color: AppConstants.textSecondaryColor,
                        fontSize: 15.0,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is NotificationFailure) {
              return Center(
                child: Text(
                  'Failed to load notifications: ${state.errorMessage}',
                  style: const TextStyle(color: AppConstants.errorColor),
                ),
              );
            }

            if (state is NotificationsLoaded) {
              final list = state.notifications;

              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined, color: AppConstants.textSecondaryColor, size: 64.0),
                      const SizedBox(height: 16.0),
                      Text(
                        'Your inbox is empty',
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamily,
                          color: AppConstants.textSecondaryColor,
                          fontSize: 15.0,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final notif = list[index];
                  return _buildNotificationCard(context, notif);
                },
              );
            }

            return const Center(child: Text('Initializing...', style: TextStyle(color: AppConstants.textSecondaryColor)));
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationModel notif) {
    return Card(
      color: notif.isRead ? AppConstants.cardColor.withValues(alpha: 0.6) : AppConstants.cardColor,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: notif.isRead
            ? BorderSide.none
            : const BorderSide(color: AppConstants.secondaryColor, width: 0.8),
      ),
      elevation: notif.isRead ? 0.0 : 3.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row - title and mark read
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (!notif.isRead)
                      Container(
                        margin: const EdgeInsets.only(right: 8.0),
                        width: 8.0,
                        height: 8.0,
                        decoration: const BoxDecoration(
                          color: AppConstants.accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Text(
                      notif.title,
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamily,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
                if (!notif.isRead)
                  IconButton(
                    icon: const Icon(Icons.mark_email_read_outlined, size: 18.0, color: AppConstants.textSecondaryColor),
                    tooltip: 'Mark as read',
                    onPressed: () {
                      context.read<NotificationBloc>().add(MarkNotificationAsRead(notif.id));
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8.0),

            // Message text
            Text(
              notif.message,
              style: const TextStyle(
                color: AppConstants.textSecondaryColor,
                fontSize: 14.0,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16.0),

            // Startup Contact Card
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: AppConstants.backgroundColor,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: AppConstants.successColor.withValues(alpha: 0.4), width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.contact_mail_outlined, color: AppConstants.successColor, size: 16.0),
                      SizedBox(width: 8.0),
                      Text(
                        'Direct Contact Details:',
                        style: TextStyle(
                          color: AppConstants.successColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Icon(Icons.email_outlined, size: 14.0, color: AppConstants.textSecondaryColor),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          notif.startupContactEmail,
                          style: const TextStyle(
                            color: AppConstants.textPrimaryColor,
                            fontSize: 13.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6.0),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 14.0, color: AppConstants.textSecondaryColor),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          notif.startupContactPhone,
                          style: const TextStyle(
                            color: AppConstants.textPrimaryColor,
                            fontSize: 13.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12.0),

            // Date notification received
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                _formatDate(notif.createdAt),
                style: TextStyle(
                  fontSize: 11.0,
                  color: AppConstants.textSecondaryColor.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
