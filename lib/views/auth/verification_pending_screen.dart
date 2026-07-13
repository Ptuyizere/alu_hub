import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/app_constants.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';

class VerificationPendingScreen extends StatelessWidget {
  const VerificationPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticatedStartup) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account verified successfully! Welcome to ALU Hub.'),
                  backgroundColor: AppConstants.successColor,
                ),
              );
            } else if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: AppConstants.errorColor,
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Icon(
                  Icons.pending_actions_outlined,
                  size: 100.0,
                  color: AppConstants.warningColor,
                ),
                const SizedBox(height: 32.0),
                Text(
                  'Verification Pending',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppConstants.fontFamily,
                    fontSize: 26.0,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Your startup profile has been created and your Rwanda Development Board (RDB) certificate is under review.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppConstants.fontFamily,
                    fontSize: 15.0,
                    color: AppConstants.textSecondaryColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12.0),
                Text(
                  'ALU Administrators will review registration. Once approved, your account will gain access to post opportunities and recruit candidates.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppConstants.fontFamily,
                    fontSize: 13.0,
                    color: AppConstants.textSecondaryColor.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48.0),
                
                // Check Verification button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    return ElevatedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () {
                              context.read<AuthBloc>().add(AuthCheckVerificationStatus());
                            },
                      icon: const Icon(Icons.refresh_outlined),
                      label: Text(
                        'Refresh Verification Status',
                        style: TextStyle(
                          fontFamily: AppConstants.fontFamily,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.secondaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    );
                  },
                ),
                const Spacer(),
                
                // Logout action
                OutlinedButton.icon(
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthSignOutRequested());
                  },
                  icon: const Icon(Icons.logout_outlined),
                  label: Text(
                    'Logout',
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamily,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConstants.errorColor,
                    side: const BorderSide(color: AppConstants.errorColor),
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
