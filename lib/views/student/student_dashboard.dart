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
import '../../blocs/notification/notification_bloc.dart';
import '../../blocs/notification/notification_event.dart';
import '../../blocs/notification/notification_state.dart';
import 'internship_detail_screen.dart';
import 'student_applications_screen.dart';
import 'student_notifications_screen.dart';

class StudentDashboard extends StatefulWidget {
  final StudentProfile studentProfile;

  const StudentDashboard({super.key, required this.studentProfile});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedRoleType;
  String? _selectedLocation;
  String? _selectedCompensation;

  @override
  void initState() {
    super.initState();
    // Load internships and notifications
    context.read<InternshipBloc>().add(LoadAllInternships());
    context.read<NotificationBloc>().add(LoadNotifications(widget.studentProfile.uid));
    
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedRoleType = null;
      _selectedLocation = null;
      _selectedCompensation = null;
    });
  }

  List<InternshipModel> _filterInternships(List<InternshipModel> list) {
    return list.where((item) {
      final matchesSearch = item.title.toLowerCase().contains(_searchQuery) ||
          item.startupName.toLowerCase().contains(_searchQuery) ||
          item.description.toLowerCase().contains(_searchQuery);
      
      final matchesRole = _selectedRoleType == null || item.roleType == _selectedRoleType;
      final matchesLocation = _selectedLocation == null || item.locationType == _selectedLocation;
      final matchesComp = _selectedCompensation == null || item.compensationType == _selectedCompensation;

      return matchesSearch && matchesRole && matchesLocation && matchesComp;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(
          'ALU Hub',
          style: TextStyle(
            fontFamily: AppConstants.fontFamily,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        backgroundColor: AppConstants.cardColor,
        elevation: 1.0,
        actions: [
          // Applications History button
          IconButton(
            icon: const Icon(Icons.history_outlined),
            tooltip: 'Application History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentApplicationsScreen(studentId: widget.studentProfile.uid),
                ),
              );
            },
          ),
          
          // Notifications button with badge
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              int unreadCount = 0;
              if (state is NotificationsLoaded) {
                unreadCount = state.notifications.where((n) => !n.isRead).length;
              }
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    tooltip: 'Notifications',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentNotificationsScreen(studentId: widget.studentProfile.uid),
                        ),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8.0,
                      top: 8.0,
                      child: Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: const BoxDecoration(
                          color: AppConstants.errorColor,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16.0,
                          minHeight: 16.0,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
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
            // Student Header welcome
            Container(
              padding: const EdgeInsets.all(16.0),
              color: AppConstants.cardColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamily,
                      fontSize: 14.0,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    widget.studentProfile.fullName,
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamily,
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimaryColor,
                    ),
                  ),
                  Text(
                    widget.studentProfile.academicProgram,
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamily,
                      fontSize: 12.0,
                      color: AppConstants.secondaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar & Filter Sheet Trigger
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: AppConstants.textPrimaryColor),
                      decoration: InputDecoration(
                        hintText: 'Search internships, skills, startups...',
                        hintStyle: const TextStyle(color: AppConstants.textSecondaryColor),
                        prefixIcon: const Icon(Icons.search, color: AppConstants.textSecondaryColor),
                        filled: true,
                        fillColor: AppConstants.cardColor,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: AppConstants.secondaryColor, width: 1.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  
                  // Filter trigger button
                  IconButton(
                    icon: Icon(
                      Icons.tune,
                      color: (_selectedRoleType != null || _selectedLocation != null || _selectedCompensation != null)
                          ? AppConstants.accentColor
                          : AppConstants.textSecondaryColor,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: AppConstants.cardColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      padding: const EdgeInsets.all(12.0),
                    ),
                    onPressed: () => _showFilterBottomSheet(context),
                  ),
                ],
              ),
            ),

            if (_selectedRoleType != null || _selectedLocation != null || _selectedCompensation != null || _searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (_selectedRoleType != null)
                              _buildFilterChip(_selectedRoleType!, () => setState(() => _selectedRoleType = null)),
                            if (_selectedLocation != null)
                              _buildFilterChip(_selectedLocation!, () => setState(() => _selectedLocation = null)),
                            if (_selectedCompensation != null)
                              _buildFilterChip(_selectedCompensation!, () => setState(() => _selectedCompensation = null)),
                            if (_searchQuery.isNotEmpty)
                              _buildFilterChip('"${_searchController.text}"', () => _searchController.clear()),
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _clearFilters,
                      child: const Text('Reset', style: TextStyle(color: AppConstants.errorColor, fontSize: 13.0)),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8.0),

            // Internships
            Expanded(
              child: BlocBuilder<InternshipBloc, InternshipState>(
                builder: (context, state) {
                  if (state is InternshipLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.work_off_outlined, color: AppConstants.textSecondaryColor, size: 64.0),
                          const SizedBox(height: 16.0),
                          Text(
                            'No internships found',
                            style: TextStyle(
                              fontFamily: AppConstants.fontFamily,
                              color: AppConstants.textSecondaryColor,
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  if (state is InternshipFailure) {
                    return Center(
                      child: Text(
                        'Failed to load opportunities: ${state.errorMessage}',
                        style: const TextStyle(color: AppConstants.errorColor),
                      ),
                    );
                  }
                  
                  if (state is AllInternshipsLoaded) {
                    final filteredList = _filterInternships(state.internships);
                    
                    if (filteredList.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.work_off_outlined, color: AppConstants.textSecondaryColor, size: 64.0),
                            const SizedBox(height: 16.0),
                            Text(
                              'No internships found',
                              style: TextStyle(
                                fontFamily: AppConstants.fontFamily,
                                color: AppConstants.textSecondaryColor,
                                fontSize: 16.0,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<InternshipBloc>().add(LoadAllInternships());
                      },
                      color: AppConstants.secondaryColor,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final item = filteredList[index];
                          return _buildInternshipCard(context, item);
                        },
                      ),
                    );
                  }

                  return const Center(child: Text('Initialize feed...', style: TextStyle(color: AppConstants.textSecondaryColor)));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11.0)),
        backgroundColor: AppConstants.secondaryColor.withValues(alpha: 0.3),
        side: const BorderSide(color: AppConstants.secondaryColor, width: 0.5),
        deleteIcon: const Icon(Icons.close, size: 14.0, color: Colors.white),
        onDeleted: onDeleted,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildInternshipCard(BuildContext context, InternshipModel item) {
    return Card(
      color: AppConstants.cardColor,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 2.0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InternshipDetailScreen(
                internship: item,
                studentProfile: widget.studentProfile,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Startup Name
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamily,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          item.startupName,
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamily,
                            fontSize: 14.0,
                            color: AppConstants.accentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_outlined, size: 16.0, color: AppConstants.textSecondaryColor),
                ],
              ),
              const SizedBox(height: 16.0),
              
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  _buildTagChip(item.roleType, Colors.blue),
                  _buildTagChip(item.locationType, Colors.orange),
                  _buildTagChip(item.compensationType, Colors.green),
                ],
              ),
              const SizedBox(height: 16.0),
              
              // Short Snippet description
              Text(
                item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppConstants.textSecondaryColor,
                  fontSize: 13.0,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12.0),
              
              // Date Posted
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 12.0, color: AppConstants.textSecondaryColor.withValues(alpha: 0.7)),
                  const SizedBox(width: 6.0),
                  Text(
                    _formatDate(item.createdAt),
                    style: TextStyle(
                      fontSize: 11.0,
                      color: AppConstants.textSecondaryColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.0),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.withValues(alpha: 0.9),
          fontSize: 11.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} days ago';
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppConstants.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Opportunities',
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamily,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textPrimaryColor,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppConstants.textSecondaryColor),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    // Role Type dropdown filter
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      dropdownColor: AppConstants.cardColor,
                      value: _selectedRoleType,
                      style: const TextStyle(color: AppConstants.textPrimaryColor),
                      decoration: const InputDecoration(
                        labelText: 'Role Type',
                        labelStyle: TextStyle(color: AppConstants.textSecondaryColor),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppConstants.textSecondaryColor)),
                      ),
                      items: AppConstants.roleTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(
                            type,
                            style: const TextStyle(fontSize: 14.0),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setModalState(() => _selectedRoleType = val);
                      },
                    ),
                    const SizedBox(height: 16.0),

                    // Location Type dropdown filter
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      dropdownColor: AppConstants.cardColor,
                      initialValue: _selectedLocation,
                      style: const TextStyle(color: AppConstants.textPrimaryColor),
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        labelStyle: TextStyle(color: AppConstants.textSecondaryColor),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppConstants.textSecondaryColor)),
                      ),
                      items: AppConstants.locationTypes.map((loc) {
                        return DropdownMenuItem<String>(
                          value: loc,
                          child: Text(
                            loc,
                            style: const TextStyle(fontSize: 14.0),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setModalState(() => _selectedLocation = val);
                      },
                    ),
                    const SizedBox(height: 16.0),

                    // Compensation Type dropdown filter
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      dropdownColor: AppConstants.cardColor,
                      initialValue: _selectedCompensation,
                      style: const TextStyle(color: AppConstants.textPrimaryColor),
                      decoration: const InputDecoration(
                        labelText: 'Compensation',
                        labelStyle: TextStyle(color: AppConstants.textSecondaryColor),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppConstants.textSecondaryColor)),
                      ),
                      items: AppConstants.compensationTypes.map((comp) {
                        return DropdownMenuItem<String>(
                          value: comp,
                          child: Text(
                            comp,
                            style: const TextStyle(fontSize: 14.0),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setModalState(() => _selectedCompensation = val);
                      },
                    ),
                    const SizedBox(height: 32.0),

                    // Apply filters button
                    ElevatedButton(
                      onPressed: () {
                        // Apply modal updates to main state
                        setState(() {});
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.secondaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      ),
                      child: Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamily,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
