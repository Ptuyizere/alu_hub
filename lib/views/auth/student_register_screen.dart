import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/app_constants.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';

class StudentRegisterScreen extends StatefulWidget {
  const StudentRegisterScreen({super.key});

  @override
  State<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends State<StudentRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _bioController = TextEditingController();
  final _skillsController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedProgram;

  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _skillsController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    if (_formKey.currentState!.validate() && _selectedProgram != null) {
      // Parse skills that are comma separated string to list
      final skillsList = _skillsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      context.read<AuthBloc>().add(
            AuthStudentRegisterRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              fullName: _fullNameController.text.trim(),
              academicProgram: _selectedProgram!,
              bio: _bioController.text.trim(),
              skills: skillsList,
              phoneNumber: _phoneController.text.trim(),
            ),
          );
    } else if (_selectedProgram == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your academic program'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Student Registration'),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        foregroundColor: AppConstants.textPrimaryColor,
      ),
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: AppConstants.errorColor,
                ),
              );
            } else if (state is AuthAuthenticatedStudent) {
              // Successfully registered navigate back to root
              Navigator.pop(context);
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create Student Account',
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamily,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Provide details to find startups seeking talent.',
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamily,
                      fontSize: 14.0,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 32.0),

                  // Full Name
                  TextFormField(
                    controller: _fullNameController,
                    style: const TextStyle(color: AppConstants.textPrimaryColor),
                    decoration: _buildInputDecoration('Full Name', Icons.person_outline),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Please enter your full name' : null,
                  ),
                  const SizedBox(height: 16.0),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: AppConstants.textPrimaryColor),
                    keyboardType: TextInputType.emailAddress,
                    decoration: _buildInputDecoration('Email Address', Icons.email_outlined),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Please enter your email';
                      final email = value.trim().toLowerCase();
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
                        return 'Please enter a valid email address';
                      }
                      if (!email.endsWith('@alustudent.com')) {
                        return 'Please use your ALU student email (@alustudent.com)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // Phone Number
                  TextFormField(
                    controller: _phoneController,
                    style: const TextStyle(color: AppConstants.textPrimaryColor),
                    keyboardType: TextInputType.phone,
                    decoration: _buildInputDecoration('Phone Number', Icons.phone_outlined),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Please enter your phone number' : null,
                  ),
                  const SizedBox(height: 16.0),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    style: const TextStyle(color: AppConstants.textPrimaryColor),
                    obscureText: _obscurePassword,
                    decoration: _buildInputDecoration('Password', Icons.lock_outline).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppConstants.textSecondaryColor,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (value) => value == null || value.length < 6 ? 'Password must be at least 6 characters' : null,
                  ),
                  const SizedBox(height: 16.0),

                  // Academic Program Dropdown
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    dropdownColor: AppConstants.cardColor,
                    initialValue: _selectedProgram,
                    style: const TextStyle(color: AppConstants.textPrimaryColor),
                    decoration: _buildInputDecoration('Academic Program', Icons.school_outlined),
                    items: AppConstants.academicPrograms.map((program) {
                      return DropdownMenuItem<String>(
                        value: program,
                        child: Text(
                          program,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedProgram = val),
                    validator: (val) => val == null ? 'Please select your program' : null,
                  ),
                  const SizedBox(height: 16.0),

                  // Skills
                  TextFormField(
                    controller: _skillsController,
                    style: const TextStyle(color: AppConstants.textPrimaryColor),
                    decoration: _buildInputDecoration('Skills (comma-separated)', Icons.star_border_outlined).copyWith(
                      helperText: 'e.g. Flutter, Dart, UI Design, Marketing',
                      helperStyle: const TextStyle(color: AppConstants.textSecondaryColor),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Please enter at least one skill' : null,
                  ),
                  const SizedBox(height: 16.0),

                  // Bio
                  TextFormField(
                    controller: _bioController,
                    style: const TextStyle(color: AppConstants.textPrimaryColor),
                    maxLines: 3,
                    decoration: _buildInputDecoration('Short Bio / About You', Icons.description_outlined),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a short bio' : null,
                  ),
                  const SizedBox(height: 32.0),

                  // Submit Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return ElevatedButton(
                        onPressed: isLoading ? null : _onRegisterPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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
                                'Register',
                                style: TextStyle(
                                  fontFamily: AppConstants.fontFamily,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      );
                    },
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
