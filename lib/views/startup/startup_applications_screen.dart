import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/app_constants.dart';
import '../../models/user_model.dart';
import '../../models/application_model.dart';
import '../../blocs/application/application_bloc.dart';
import '../../blocs/application/application_event.dart';
import '../../blocs/application/application_state.dart';
import 'application_detail_screen.dart';

class StartupApplicationsScreen extends StatefulWidget {
  final StartupProfile startupProfile;

  const StartupApplicationsScreen({super.key, required this.startupProfile});

  @override
  State<StartupApplicationsScreen> createState() => _StartupApplicationsScreenState();
}

class _StartupApplicationsScreenState extends State<StartupApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ApplicationBloc>().add(LoadStartupApplications(widget.startupProfile.uid));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Candidate Applications'),
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
                    Icon(Icons.assignment_ind_outlined, color: AppConstants.textSecondaryColor, size: 64.0),
                    const SizedBox(height: 16.0),
                    Text(
                      'No student applications received yet.',
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
                  'Failed to load applications: ${state.errorMessage}',
                  style: const TextStyle(color: AppConstants.errorColor),
                ),
              );
            }

            if (state is StartupApplicationsLoaded) {
              final list = state.applications;

              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_ind_outlined, color: AppConstants.textSecondaryColor, size: 64.0),
                      const SizedBox(height: 16.0),
                      Text(
                        'No student applications received yet.',
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
      elevation: 2.0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ApplicationDetailScreen(
                application: app,
                startupProfile: widget.startupProfile,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Applicant Name and Status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      app.studentName,
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamily,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
                  ),
                  _buildStatusBadge(app.status),
                ],
              ),
              const SizedBox(height: 4.0),

              // Applied position
              Text(
                'Applied for: ${app.internshipTitle}',
                style: TextStyle(
                  fontFamily: AppConstants.fontFamily,
                  fontSize: 13.0,
                  color: AppConstants.accentColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12.0),

              // Academic Program
              Row(
                children: [
                  const Icon(Icons.school_outlined, size: 14.0, color: AppConstants.textSecondaryColor),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      app.studentProgram,
                      style: const TextStyle(color: AppConstants.textSecondaryColor, fontSize: 13.0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Action link indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Review Application',
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamily,
                      fontSize: 12.0,
                      color: AppConstants.secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  const Icon(Icons.arrow_forward_ios_outlined, size: 12.0, color: AppConstants.secondaryColor),
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
          fontSize: 10.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
