import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/app_constants.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import 'student_register_screen.dart';
import 'startup_register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.errorMessage,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: AppConstants.errorColor,
                ),
              );
            }
          },
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo & Title
                    Icon(
                      Icons.hub_outlined,
                      size: 80.0,
                      color: AppConstants.secondaryColor,
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'ALU HUB',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamily,
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimaryColor,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Bridging ALU Rwanda Students & Startups',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamily,
                        fontSize: 14.0,
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 48.0),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: AppConstants.textPrimaryColor),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        labelStyle: const TextStyle(color: AppConstants.textSecondaryColor),
                        prefixIcon: const Icon(Icons.email_outlined, color: AppConstants.textSecondaryColor),
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
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email address';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20.0),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      style: const TextStyle(color: AppConstants.textPrimaryColor),
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: AppConstants.textSecondaryColor),
                        prefixIcon: const Icon(Icons.lock_outline, color: AppConstants.textSecondaryColor),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppConstants.textSecondaryColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
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
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32.0),

                    // Login Button
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;
                        return ElevatedButton(
                          onPressed: isLoading ? null : _onLoginPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            elevation: 2.0,
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
                                  'Login',
                                  style: TextStyle(
                                    fontFamily: AppConstants.fontFamily,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          );
                      },
                    ),
                    const SizedBox(height: 32.0),

                    // Separation Divider
                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppConstants.cardColor)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'NEW TO ALU HUB?',
                            style: TextStyle(
                              fontFamily: AppConstants.fontFamily,
                              color: AppConstants.textSecondaryColor,
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: AppConstants.cardColor)),
                      ],
                    ),
                    const SizedBox(height: 24.0),

                    // Register Buttons
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StudentRegisterScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppConstants.textPrimaryColor,
                        side: const BorderSide(color: AppConstants.cardColor),
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: Text(
                        'Register as Student',
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamily,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StartupRegisterScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppConstants.secondaryColor,
                        side: const BorderSide(color: AppConstants.secondaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: Text(
                        'Register as Startup',
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamily,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
