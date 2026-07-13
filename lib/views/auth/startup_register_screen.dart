import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../constants/app_constants.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';

class StartupRegisterScreen extends StatefulWidget {
  const StartupRegisterScreen({super.key});

  @override
  State<StartupRegisterScreen> createState() => _StartupRegisterScreenState();
}

class _StartupRegisterScreenState extends State<StartupRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _websiteController = TextEditingController();
  final _industryController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _pdfPath;
  Uint8List? _pdfBytes;
  String? _pdfName;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _companyNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _industryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickRdbCertificate() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.extension == 'pdf') {
        setState(() {
          _pdfName = result.files.single.name;
          if (kIsWeb) {
            _pdfBytes = result.files.single.bytes;
          } else {
            _pdfPath = result.files.single.path;
            _pdfBytes = result.files.single.bytes;
          }
        });
      } else {
        // User cancelled or picked a file that is not a pdf
        if (mounted && result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a PDF file only.'),
              backgroundColor: AppConstants.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File picking error: $e'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  void _onRegisterPressed() {
    if (_formKey.currentState!.validate()) {
      if (_pdfPath == null && _pdfBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload your RDB Registration Certificate PDF'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
        return;
      }

      context.read<AuthBloc>().add(
            AuthStartupRegisterRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              companyName: _companyNameController.text.trim(),
              description: _descriptionController.text.trim(),
              website: _websiteController.text.trim(),
              industry: _industryController.text.trim(),
              phoneNumber: _phoneController.text.trim(),
              filePath: _pdfPath,
              fileBytes: _pdfBytes,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Startup Registration'),
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
            } else if (state is AuthUnverifiedStartup) {
              // Successfully registered but unverified
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
                    'Register Your Startup',
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamily,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Complete the form and upload your RDB registration certificate to start recruiting ALU talent.',
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamily,
                      fontSize: 14.0,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 32.0),

                  // Company Name
                  TextFormField(
                    controller: _companyNameController,
                    style: const TextStyle(color: AppConstants.textPrimaryColor),
                    decoration: _buildInputDecoration('Company Name', Icons.business_outlined),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Please enter company name' : null,
                  ),
                  const SizedBox(height: 16.0),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: AppConstants.textPrimaryColor),
                    keyboardType: TextInputType.emailAddress,
                    decoration: _buildInputDecoration('Contact Email', Icons.email_outlined),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Please enter company email';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) return 'Please enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // Phone Number
                  TextFormField(
                    controller: _phoneController,
                    style: const TextStyle(color: AppConstants.textPrimaryColor),
                    keyboardType: TextInputType.phone,
                    decoration: _buildInputDecoration('Contact Phone Number', Icons.phone_outlined),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Please enter company contact phone' : null,
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

                  // Website
                  TextFormField(
                    controller: _websiteController,
                    style: const TextStyle(color: AppConstants.textPrimaryColor),
                    keyboardType: TextInputType.url,
                    decoration: _buildInputDecoration('Website URL', Icons.language_outlined),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Please enter company website URL' : null,
                  ),
                  const SizedBox(height: 16.0),

                  // Industry
                  TextFormField(
                    controller: _industryController,
                    style: const TextStyle(color: AppConstants.textPrimaryColor),
                    decoration: _buildInputDecoration('Industry Sector', Icons.category_outlined),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Please enter industry sector' : null,
                  ),
                  const SizedBox(height: 16.0),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    style: const TextStyle(color: AppConstants.textPrimaryColor),
                    maxLines: 3,
                    decoration: _buildInputDecoration('Company Description', Icons.description_outlined),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Please enter company description' : null,
                  ),
                  const SizedBox(height: 24.0),

                  // RDB Certificate Upload Area
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppConstants.cardColor,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: AppConstants.secondaryColor.withValues(alpha: 0.5), width: 1.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.picture_as_pdf_outlined, color: AppConstants.secondaryColor, size: 28.0),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'RDB Registration Certificate',
                                    style: TextStyle(
                                      fontFamily: AppConstants.fontFamily,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                      color: AppConstants.textPrimaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2.0),
                                  Text(
                                    'Upload Rwanda Development Board PDF registration certificate',
                                    style: TextStyle(
                                      fontFamily: AppConstants.fontFamily,
                                      fontSize: 11.0,
                                      color: AppConstants.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        ElevatedButton.icon(
                          onPressed: _pickRdbCertificate,
                          icon: const Icon(Icons.upload_file_outlined),
                          label: Text(
                            _pdfName == null ? 'Select PDF Certificate' : 'Change Certificate',
                            style: TextStyle(fontFamily: AppConstants.fontFamily),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: AppConstants.accentColor,
                            elevation: 0.0,
                            side: const BorderSide(color: AppConstants.accentColor),
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                          ),
                        ),
                        if (_pdfName != null) ...[
                          const SizedBox(height: 12.0),
                          Row(
                            children: [
                              const Icon(Icons.check_circle_outline, color: AppConstants.successColor, size: 16.0),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: Text(
                                  _pdfName!,
                                  style: const TextStyle(
                                    color: AppConstants.successColor,
                                    fontSize: 13.0,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
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
                                'Submit Profile for Verification',
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
