import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/app_constants.dart';
import '../../models/user_model.dart';
import '../../models/internship_model.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/internship/internship_bloc.dart';
import '../../blocs/internship/internship_event.dart';
import '../../blocs/internship/internship_state.dart';
import 'post_internship_screen.dart';
import 'startup_applications_screen.dart';

class StartupDashboard extends StatefulWidget {
  final StartupProfile startupProfile;

  const StartupDashboard({super.key, required this.startupProfile});

  @override
  State<StartupDashboard> createState() => _StartupDashboardState();
}

class _StartupDashboardState extends State<StartupDashboard> {
  @override
  void initState() {
    super.initState();
    // Fetch this startup postings
    context.read<InternshipBloc>().add(LoadStartupInternships(widget.startupProfile.uid));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.startupProfile.companyName,
          style: TextStyle(
            fontFamily: AppConstants.fontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppConstants.cardColor,
        foregroundColor: AppConstants.textPrimaryColor,
        elevation: 1.0,
        actions: [
          // Applications review page button
          IconButton(
            icon: const Icon(Icons.people_alt_outlined),
            tooltip: 'Review Student Applications',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StartupApplicationsScreen(
                    startupProfile: widget.startupProfile,
                  ),
                ),
              );
            },
          ),
          
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Logout',
            onPressed: () {
              context.read<AuthBloc>().add(AuthSignOutRequested());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header showing profile status
            Container(
              padding: const EdgeInsets.all(16.0),
              color: AppConstants.cardColor,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Verified Employer Profile',
                              style: TextStyle(
                                fontFamily: AppConstants.fontFamily,
                                fontSize: 13.0,
                                color: AppConstants.successColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4.0),
                            const Icon(Icons.verified, color: AppConstants.successColor, size: 16.0),
                          ],
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          widget.startupProfile.industry,
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamily,
                            fontSize: 14.0,
                            color: AppConstants.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StartupApplicationsScreen(
                            startupProfile: widget.startupProfile,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.assignment_ind_outlined, size: 16.0),
                    label: const Text('Applications', style: TextStyle(fontSize: 12.0)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppConstants.accentColor,
                      side: const BorderSide(color: AppConstants.accentColor),
                    ),
                  ),
                ],
              ),
            ),

            // Section Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
              child: Text(
                'My Posted Opportunities',
                style: TextStyle(
                  fontFamily: AppConstants.fontFamily,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
            ),

            // Internships
            Expanded(
              child: BlocBuilder<InternshipBloc, InternshipState>(
                builder: (context, state) {
                  if (state is InternshipLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.post_add_outlined, color: AppConstants.textSecondaryColor, size: 64.0),
                          const SizedBox(height: 16.0),
                          Text(
                            'No internships posted yet.',
                            style: TextStyle(
                              fontFamily: AppConstants.fontFamily,
                              color: AppConstants.textSecondaryColor,
                              fontSize: 15.0,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          Text(
                            'Click the "+" button below to post one.',
                            style: TextStyle(
                              fontFamily: AppConstants.fontFamily,
                              color: AppConstants.textSecondaryColor.withValues(alpha: 0.7),
                              fontSize: 13.0,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is InternshipFailure) {
                    return Center(
                      child: Text(
                        'Error loading opportunities: ${state.errorMessage}',
                        style: const TextStyle(color: AppConstants.errorColor),
                      ),
                    );
                  }

                  if (state is StartupInternshipsLoaded) {
                    final list = state.internships;

                    if (list.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.post_add_outlined, color: AppConstants.textSecondaryColor, size: 64.0),
                            const SizedBox(height: 16.0),
                            Text(
                              'No internships posted yet.',
                              style: TextStyle(
                                fontFamily: AppConstants.fontFamily,
                                color: AppConstants.textSecondaryColor,
                                fontSize: 15.0,
                              ),
                            ),
                            const SizedBox(height: 12.0),
                            Text(
                              'Click the "+" button below to post one.',
                              style: TextStyle(
                                fontFamily: AppConstants.fontFamily,
                                color: AppConstants.textSecondaryColor.withValues(alpha: 0.7),
                                fontSize: 13.0,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final item = list[index];
                        return _buildOpportunityCard(context, item);
                      },
                    );
                  }

                  return const Center(child: Text('Initializing posts...', style: TextStyle(color: AppConstants.textSecondaryColor)));
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostInternshipScreen(
                startupProfile: widget.startupProfile,
              ),
            ),
          );
        },
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        tooltip: 'Post Opportunity',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildOpportunityCard(BuildContext context, InternshipModel item) {
    return Card(
      color: AppConstants.cardColor,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Edit/Delete Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamily,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimaryColor,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20.0, color: AppConstants.textSecondaryColor),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostInternshipScreen(
                              startupProfile: widget.startupProfile,
                              internshipToEdit: item,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_outlined, size: 20.0, color: AppConstants.errorColor),
                      onPressed: () => _confirmDelete(context, item.id),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8.0),

            // Chips
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: AppConstants.backgroundColor,
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(
                    item.roleType,
                    style: const TextStyle(color: AppConstants.textSecondaryColor, fontSize: 11.0),
                  ),
                ),
                const SizedBox(width: 8.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: AppConstants.backgroundColor,
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(
                    '${item.locationType} • ${item.compensationType}',
                    style: const TextStyle(color: AppConstants.textSecondaryColor, fontSize: 11.0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            const Divider(color: AppConstants.backgroundColor, height: 1.0),
            const SizedBox(height: 12.0),

            // Active/Inactive toggle switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      item.isActive ? Icons.check_circle_outline : Icons.pause_circle_outline,
                      size: 16.0,
                      color: item.isActive ? AppConstants.successColor : AppConstants.textSecondaryColor,
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      item.isActive ? 'Active Listing' : 'Closed Listing',
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamily,
                        fontSize: 12.0,
                        color: item.isActive ? AppConstants.successColor : AppConstants.textSecondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: item.isActive,
                    activeThumbColor: AppConstants.successColor,
                    activeTrackColor: AppConstants.successColor.withValues(alpha: 0.3),
                    inactiveThumbColor: AppConstants.textSecondaryColor,
                    inactiveTrackColor: AppConstants.cardColor,
                    onChanged: (bool value) {
                      context.read<InternshipBloc>().add(
                            ToggleInternshipActiveStatus(item.id, value),
                          );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String internshipId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppConstants.cardColor,
          title: const Text('Delete Opportunity?', style: TextStyle(color: AppConstants.textPrimaryColor)),
          content: const Text(
            'Are you sure you want to permanently delete this opportunity? This cannot be undone.',
            style: TextStyle(color: AppConstants.textSecondaryColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppConstants.textSecondaryColor)),
            ),
            TextButton(
              onPressed: () {
                context.read<InternshipBloc>().add(DeleteInternship(internshipId));
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: AppConstants.errorColor)),
            ),
          ],
        );
      },
    );
  }
}
