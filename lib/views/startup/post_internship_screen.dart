import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/app_constants.dart';
import '../../models/user_model.dart';
import '../../models/internship_model.dart';
import '../../blocs/internship/internship_bloc.dart';
import '../../blocs/internship/internship_event.dart';
import '../../blocs/internship/internship_state.dart';

class PostInternshipScreen extends StatefulWidget {
  final StartupProfile startupProfile;
  final InternshipModel? internshipToEdit;

  const PostInternshipScreen({
    super.key,
    required this.startupProfile,
    this.internshipToEdit,
  });

  @override
  State<PostInternshipScreen> createState() => _PostInternshipScreenState();
}

class _PostInternshipScreenState extends State<PostInternshipScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _salaryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();

  String? _selectedRoleType;
  String? _selectedLocation;
  String? _selectedCompensation;
  bool _isSubmitting = false;

  bool get isEditMode => widget.internshipToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      final item = widget.internshipToEdit!;
      _titleController.text = item.title;
      _salaryController.text = item.salaryRange;
      _descriptionController.text = item.description;
      _requirementsController.text = item.requirements;
      _selectedRoleType = item.roleType;
      _selectedLocation = item.locationType;
      _selectedCompensation = item.compensationType;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _salaryController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    super.dispose();
  }

  void _onSubmitPressed() {
    if (_formKey.currentState!.validate() &&
        _selectedRoleType != null &&
        _selectedLocation != null &&
        _selectedCompensation != null) {
      
      setState(() {
        _isSubmitting = true;
      });

      final internship = InternshipModel(
        id: isEditMode ? widget.internshipToEdit!.id : '',
        startupId: widget.startupProfile.uid,
        startupName: widget.startupProfile.companyName,
        title: _titleController.text.trim(),
        roleType: _selectedRoleType!,
        locationType: _selectedLocation!,
        compensationType: _selectedCompensation!,
        salaryRange: _salaryController.text.trim(),
        description: _descriptionController.text.trim(),
        requirements: _requirementsController.text.trim(),
        createdAt: isEditMode ? widget.internshipToEdit!.createdAt : DateTime.now(),
        isActive: isEditMode ? widget.internshipToEdit!.isActive : true,
      );

      if (isEditMode) {
        context.read<InternshipBloc>().add(UpdateInternship(internship));
      } else {
        context.read<InternshipBloc>().add(CreateInternship(internship));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select all dropdown field options'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InternshipBloc, InternshipState>(
      listener: (context, state) {
        if (state is InternshipOperationSuccess) {
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditMode ? 'Opportunity updated successfully!' : 'Opportunity posted successfully!'),
              backgroundColor: AppConstants.successColor,
            ),
          );
          Navigator.pop(context); // To Dashboard
        } else if (state is InternshipFailure) {
          setState(() {
            _isSubmitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Operation failed: ${state.errorMessage}'),
              backgroundColor: AppConstants.errorColor,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        appBar: AppBar(
          title: Text(isEditMode ? 'Edit Opportunity' : 'Post Internship'),
          backgroundColor: AppConstants.cardColor,
          foregroundColor: AppConstants.textPrimaryColor,
          elevation: 1.0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isEditMode ? 'Modify Listing' : 'Create New Posting',
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamily,
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Specify internship details to match with seeking ALU students.',
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamily,
                      fontSize: 13.0,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 32.0),

                  // Job Title
                  TextFormField(
                    controller: _titleController,
                    style: const TextStyle(color: AppConstants.textPrimaryColor),
                    decoration: _buildInputDecoration('Opportunity Title', Icons.work_outline),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: 16.0),

                  // Role Type Dropdown
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    dropdownColor: AppConstants.cardColor,
                    initialValue: _selectedRoleType,
                    style: const TextStyle(color: AppConstants.textPrimaryColor),
                    decoration: _buildInputDecoration('Role Area / Category', Icons.category_outlined),
                    items: AppConstants.roleTypes.map((role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(
                          role,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedRoleType = val),
                    validator: (val) => val == null ? 'Please select category' : null,
                  ),
                  const SizedBox(height: 16.0),

                  // Location Type Dropdown
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    dropdownColor: AppConstants.cardColor,
                    initialValue: _selectedLocation,
                    style: const TextStyle(color: AppConstants.textPrimaryColor),
                    decoration: _buildInputDecoration('Location Type', Icons.place_outlined),
                    items: AppConstants.locationTypes.map((loc) {
                      return DropdownMenuItem<String>(
                        value: loc,
                        child: Text(
                          loc,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedLocation = val),
                    validator: (val) => val == null ? 'Please select location type' : null,
                  ),
                  const SizedBox(height: 16.0),

                  // Compensation Type Dropdown
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    dropdownColor: AppConstants.cardColor,
                    initialValue: _selectedCompensation,
                    style: const TextStyle(color: AppConstants.textPrimaryColor),
                    decoration: _buildInputDecoration('Compensation Type', Icons.monetization_on_outlined),
                    items: AppConstants.compensationTypes.map((comp) {
                      return DropdownMenuItem<String>(
                        value: comp,
                        child: Text(
                          comp,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedCompensation = val),
                    validator: (val) => val == null ? 'Please select compensation type' : null,
                  ),
                  const SizedBox(height: 16.0),

                  // Compensation description
                  TextFormField(
                    controller: _salaryController,
                    style: const TextStyle(color: AppConstants.textPrimaryColor),
                    decoration: _buildInputDecoration('Compensation Details (optional)', Icons.payments_outlined).copyWith(
                      helperText: 'e.g. \$200/month, Shares: 1% equity, Unpaid',
                      helperStyle: const TextStyle(color: AppConstants.textSecondaryColor),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    style: const TextStyle(color: AppConstants.textPrimaryColor),
                    maxLines: 4,
                    decoration: _buildInputDecoration('Role Description & Scope', Icons.description_outlined),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Please enter role description' : null,
                  ),
                  const SizedBox(height: 16.0),

                  // Requirements
                  TextFormField(
                    controller: _requirementsController,
                    style: const TextStyle(color: AppConstants.textPrimaryColor),
                    maxLines: 4,
                    decoration: _buildInputDecoration('Skills & Requirements Needed', Icons.assignment_turned_in_outlined),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Please list requirements' : null,
                  ),
                  const SizedBox(height: 32.0),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _onSubmitPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20.0,
                            width: 20.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            isEditMode ? 'Update Posting' : 'Publish Opportunity',
                            style: TextStyle(
                              fontFamily: AppConstants.fontFamily,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppConstants.textSecondaryColor),
      prefixIcon: Icon(icon, color: AppConstants.textSecondaryColor),
      filled: true,
      fillColor: AppConstants.cardColor,
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
    );
  }
}
