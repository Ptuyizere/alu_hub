import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/app_constants.dart';
import '../../models/application_model.dart';
import '../../models/user_model.dart';
import '../../repositories/auth_repository.dart';
import '../../blocs/application/application_bloc.dart';
import '../../blocs/application/application_event.dart';
import '../../blocs/application/application_state.dart';

class ApplicationDetailScreen extends StatefulWidget {
  final ApplicationModel application;
  final StartupProfile startupProfile;

  const ApplicationDetailScreen({
    super.key,
    required this.application,
    required this.startupProfile,
  });

  @override
  State<ApplicationDetailScreen> createState() => _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  late Future<StudentProfile> _studentProfileFuture;
  final AuthRepository _authRepository = AuthRepository();

  @override
  void initState() {
    super.initState();
    _studentProfileFuture = _authRepository.getStudentProfile(widget.application.studentId);
  }

  void _updateStatus(String status) {
    context.read<ApplicationBloc>().add(
          UpdateApplicationStatusEvent(
            applicationId: widget.application.id,
            status: status,
            startupInfo: widget.startupProfile,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ApplicationBloc, ApplicationState>(
      listener: (context, state) {
        if (state is StartupApplicationsLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Application review updated!'),
              backgroundColor: AppConstants.successColor,
            ),
          );
          Navigator.pop(context);
        } else if (state is ApplicationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update status: ${state.errorMessage}'),
              backgroundColor: AppConstants.errorColor,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        appBar: AppBar(
          title: const Text('Review Application'),
          backgroundColor: AppConstants.cardColor,
          foregroundColor: AppConstants.textPrimaryColor,
          elevation: 1.0,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card - Candidate and Position
                      Text(
                        widget.application.studentName,
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamily,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        widget.application.studentProgram,
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamily,
                          fontSize: 14.0,
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Position: ${widget.application.internshipTitle}',
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamily,
                          fontSize: 14.0,
                          color: AppConstants.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      // FutureBuilder loading full student profile
                      FutureBuilder<StudentProfile>(
                        future: _studentProfileFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 24.0),
                                child: CircularProgressIndicator(color: AppConstants.secondaryColor),
                              ),
                            );
                          }
                          
                          if (snapshot.hasError) {
                            return Container(
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: AppConstants.errorColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                'Could not fetch full profile details: ${snapshot.error}',
                                style: const TextStyle(color: AppConstants.errorColor, fontSize: 13.0),
                              ),
                            );
                          }

                          if (snapshot.hasData) {
                            final profile = snapshot.data!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Bio section
                                Text(
                                  'Candidate Bio',
                                  style: TextStyle(
                                    fontFamily: AppConstants.fontFamily,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: AppConstants.textPrimaryColor,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  profile.bio,
                                  style: const TextStyle(color: AppConstants.textSecondaryColor, fontSize: 14.0, height: 1.5),
                                ),
                                const SizedBox(height: 24.0),

                                // Skills section
                                Text(
                                  'Skills & Core Competencies',
                                  style: TextStyle(
                                    fontFamily: AppConstants.fontFamily,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: AppConstants.textPrimaryColor,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children: profile.skills.map((skill) {
                                    return Chip(
                                      label: Text(skill, style: const TextStyle(color: Colors.white, fontSize: 12.0)),
                                      backgroundColor: AppConstants.secondaryColor.withValues(alpha:0.2),
                                      side: const BorderSide(color: AppConstants.secondaryColor, width: 0.5),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 24.0),
                              ],
                            );
                          }

                          return const SizedBox();
                        },
                      ),

                      // Cover Letter Box
                      Text(
                        'Cover Letter',
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamily,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: AppConstants.cardColor,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          widget.application.coverLetter,
                          style: const TextStyle(
                            color: AppConstants.textPrimaryColor,
                            fontSize: 14.0,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32.0),
                    ],
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                decoration: const BoxDecoration(
                  color: AppConstants.cardColor,
                  border: Border(top: BorderSide(color: AppConstants.backgroundColor, width: 2.0)),
                ),
                child: widget.application.status == 'pending'
                    ? Row(
                        children: [
                          // Reject Button
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _updateStatus('rejected'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppConstants.errorColor,
                                side: const BorderSide(color: AppConstants.errorColor),
                                padding: const EdgeInsets.symmetric(vertical: 14.0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                              ),
                              child: Text(
                                'Decline',
                                style: TextStyle(
                                  fontFamily: AppConstants.fontFamily,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          
                          // Approve Button
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _updateStatus('approved'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppConstants.successColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14.0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                              ),
                              child: Text(
                                'Approve',
                                style: TextStyle(
                                  fontFamily: AppConstants.fontFamily,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Text(
                          widget.application.status == 'approved'
                              ? 'This application has been APPROVED'
                              : 'This application has been DECLINED',
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamily,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: widget.application.status == 'approved'
                                ? AppConstants.successColor
                                : AppConstants.errorColor,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
