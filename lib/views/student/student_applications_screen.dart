import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/app_constants.dart';
import '../../models/application_model.dart';
import '../../blocs/application/application_bloc.dart';
import '../../blocs/application/application_event.dart';
import '../../blocs/application/application_state.dart';

class StudentApplicationsScreen extends StatefulWidget {
  final String studentId;

  const StudentApplicationsScreen({super.key, required this.studentId});

  @override
  State<StudentApplicationsScreen> createState() => _StudentApplicationsScreenState();
}

class _StudentApplicationsScreenState extends State<StudentApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ApplicationBloc>().add(LoadStudentApplications(widget.studentId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('My Applications'),
        backgroundColor: AppConstants.cardColor,
        foregroundColor: AppConstants.textPrimaryColor,
        elevation: 1.0,
      ),
      body: SafeArea(
        child: BlocBuilder<ApplicationBloc, ApplicationState>(
          builder: (context, state) {
            if (state is ApplicationLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment_outlined, color: AppConstants.textSecondaryColor, size: 64.0),
                    const SizedBox(height: 16.0),
                    Text(
                      'You haven\'t applied to any internships yet.',
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

            if (state is ApplicationFailure) {
              return Center(
                child: Text(
                  'Error loading applications: ${state.errorMessage}',
                  style: const TextStyle(color: AppConstants.errorColor),
                ),
              );
            }

            if (state is StudentApplicationsLoaded) {
              final list = state.applications;

              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_outlined, color: AppConstants.textSecondaryColor, size: 64.0),
                      const SizedBox(height: 16.0),
                      Text(
                        'You haven\'t applied to any internships yet.',
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
                  final app = list[index];
                  return _buildApplicationCard(context, app);
                },
              );
            }

            return const Center(child: Text('Initializing...', style: TextStyle(color: AppConstants.textSecondaryColor)));
          },
        ),
      ),
    );
  }

  Widget _buildApplicationCard(BuildContext context, ApplicationModel app) {
    return Card(
      color: AppConstants.cardColor,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 1.0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () => _showCoverLetterDialog(context, app),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      app.internshipTitle,
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamily,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
                  ),
                  _buildStatusBadge(app.status),
                ],
              ),
              const SizedBox(height: 12.0),
              
              // Date submitted
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 12.0, color: AppConstants.textSecondaryColor),
                  const SizedBox(width: 6.0),
                  Text(
                    'Applied on: ${_formatDate(app.createdAt)}',
                    style: const TextStyle(color: AppConstants.textSecondaryColor, fontSize: 12.0),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              
              // Small hint to view details
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Tap to view cover letter',
                    style: TextStyle(
                      fontSize: 11.0,
                      color: AppConstants.secondaryColor.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  Icon(Icons.open_in_new, size: 12.0, color: AppConstants.secondaryColor.withValues(alpha: 0.8)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    String label;
    
    switch (status) {
      case 'approved':
        badgeColor = AppConstants.successColor;
        label = 'Approved';
        break;
      case 'rejected':
        badgeColor = AppConstants.errorColor;
        label = 'Declined';
        break;
      default:
        badgeColor = AppConstants.warningColor;
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: badgeColor, width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: badgeColor,
          fontSize: 11.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showCoverLetterDialog(BuildContext context, ApplicationModel app) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppConstants.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Application Pitch',
                style: TextStyle(
                  fontFamily: AppConstants.fontFamily,
                  color: AppConstants.textPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                app.internshipTitle,
                style: const TextStyle(
                  color: AppConstants.textSecondaryColor,
                  fontSize: 13.0,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Divider(color: AppConstants.backgroundColor),
                const SizedBox(height: 8.0),
                Text(
                  app.coverLetter,
                  style: const TextStyle(
                    color: AppConstants.textPrimaryColor,
                    fontSize: 14.0,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: AppConstants.secondaryColor)),
            ),
          ],
        );
      },
    );
  }
}
