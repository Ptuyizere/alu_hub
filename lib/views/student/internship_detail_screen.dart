import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/app_constants.dart';
import '../../models/internship_model.dart';
import '../../models/user_model.dart';
import '../../models/application_model.dart';
import '../../blocs/application/application_bloc.dart';
import '../../blocs/application/application_event.dart';
import '../../blocs/application/application_state.dart';

class InternshipDetailScreen extends StatefulWidget {
  final InternshipModel internship;
  final StudentProfile studentProfile;

  const InternshipDetailScreen({
    super.key,
    required this.internship,
    required this.studentProfile,
  });

  @override
  State<InternshipDetailScreen> createState() => _InternshipDetailScreenState();
}

class _InternshipDetailScreenState extends State<InternshipDetailScreen> {
  final _coverLetterController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _coverLetterController.dispose();
    super.dispose();
  }

  void _onApplyPressed() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppConstants.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Apply for Position',
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamily,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '${widget.internship.title} at ${widget.internship.startupName}',
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamily,
                      fontSize: 14.0,
                      color: AppConstants.accentColor,
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // Cover Letter Field
                  TextFormField(
                    controller: _coverLetterController,
                    maxLines: 6,
                    style: const TextStyle(color: AppConstants.textPrimaryColor),
                    decoration: InputDecoration(
                      labelText: 'Cover Letter / Pitch',
                      labelStyle: const TextStyle(color: AppConstants.textSecondaryColor),
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: AppConstants.backgroundColor,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(color: AppConstants.secondaryColor, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(color: AppConstants.errorColor, width: 1.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(color: AppConstants.errorColor, width: 1.5),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a cover letter explaining why you are a good fit.';
                      }
                      if (value.trim().length < 50) {
                        return 'Please write at least 50 characters to express your motivation.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24.0),

                  // Submit Application Button
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final application = ApplicationModel(
                          id: '',
                          internshipId: widget.internship.id,
                          studentId: widget.studentProfile.uid,
                          startupId: widget.internship.startupId,
                          studentName: widget.studentProfile.fullName,
                          studentEmail: widget.studentProfile.email,
                          studentProgram: widget.studentProfile.academicProgram,
                          internshipTitle: widget.internship.title,
                          coverLetter: _coverLetterController.text.trim(),
                          status: 'pending',
                          createdAt: DateTime.now(),
                        );

                        context.read<ApplicationBloc>().add(SubmitApplication(application));
                        Navigator.pop(context); // Close bottom sheet
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text(
                      'Submit Application',
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ApplicationBloc, ApplicationState>(
      listener: (context, state) {
        if (state is ApplicationOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Application submitted successfully!'),
              backgroundColor: AppConstants.successColor,
            ),
          );
          Navigator.pop(context);
        } else if (state is ApplicationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to submit application: ${state.errorMessage}'),
              backgroundColor: AppConstants.errorColor,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        appBar: AppBar(
          title: const Text('Internship Details'),
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
                      // Job Title
                      Text(
                        widget.internship.title,
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamily,
                          fontSize: 26.0,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 8.0),

                      // Startup Name
                      Text(
                        widget.internship.startupName,
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamily,
                          fontSize: 16.0,
                          color: AppConstants.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      // Details
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: AppConstants.cardColor,
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfoColumn(Icons.work_outline, 'Role', widget.internship.roleType),
                            _buildInfoColumn(Icons.place_outlined, 'Location', widget.internship.locationType),
                            _buildInfoColumn(Icons.monetization_on_outlined, 'Type', widget.internship.compensationType),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      // Salary/Equity info
                      if (widget.internship.salaryRange.isNotEmpty) ...[
                        Text(
                          'Compensation Detail',
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamily,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          widget.internship.salaryRange,
                          style: const TextStyle(
                            color: AppConstants.textSecondaryColor,
                            fontSize: 15.0,
                          ),
                        ),
                        const SizedBox(height: 24.0),
                      ],

                      // Description
                      Text(
                        'Role Description',
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamily,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        widget.internship.description,
                        style: const TextStyle(
                          color: AppConstants.textSecondaryColor,
                          fontSize: 14.0,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      // Requirements
                      Text(
                        'Requirements & Qualifications',
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamily,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        widget.internship.requirements,
                        style: const TextStyle(
                          color: AppConstants.textSecondaryColor,
                          fontSize: 14.0,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Apply Panel
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                decoration: const BoxDecoration(
                  color: AppConstants.cardColor,
                  border: Border(
                    top: BorderSide(color: AppConstants.backgroundColor, width: 2.0),
                  ),
                ),
                child: BlocBuilder<ApplicationBloc, ApplicationState>(
                  builder: (context, state) {
                    final isLoading = state is ApplicationLoading;
                    return ElevatedButton(
                      onPressed: isLoading ? null : _onApplyPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20.0,
                              width: 20.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Apply Now',
                              style: TextStyle(
                                fontFamily: AppConstants.fontFamily,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppConstants.secondaryColor, size: 24.0),
        const SizedBox(height: 8.0),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppConstants.fontFamily,
            fontSize: 11.0,
            color: AppConstants.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppConstants.fontFamily,
            fontSize: 13.0,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimaryColor,
          ),
        ),
      ],
    );
  }
}
