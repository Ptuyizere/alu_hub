import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'constants/app_constants.dart';
import 'repositories/auth_repository.dart';
import 'repositories/internship_repository.dart';
import 'repositories/application_repository.dart';
import 'repositories/notification_repository.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/auth/auth_state.dart';
import 'blocs/internship/internship_bloc.dart';
import 'blocs/application/application_bloc.dart';
import 'blocs/notification/notification_bloc.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/verification_pending_screen.dart';
import 'views/student/student_dashboard.dart';
import 'views/startup/startup_dashboard.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
    );
  } catch (e) {
    debugPrint("Firebase initialization info (configuration required for runtime): $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Init repositories
    final authRepository = AuthRepository();
    final internshipRepository = InternshipRepository();
    final applicationRepository = ApplicationRepository();
    final notificationRepository = NotificationRepository();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<InternshipRepository>.value(value: internshipRepository),
        RepositoryProvider<ApplicationRepository>.value(value: applicationRepository),
        RepositoryProvider<NotificationRepository>.value(value: notificationRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(authRepository: authRepository)..add(AuthCheckRequested()),
          ),
          BlocProvider<InternshipBloc>(
            create: (context) => InternshipBloc(internshipRepository: internshipRepository),
          ),
          BlocProvider<ApplicationBloc>(
            create: (context) => ApplicationBloc(applicationRepository: applicationRepository),
          ),
          BlocProvider<NotificationBloc>(
            create: (context) => NotificationBloc(notificationRepository: notificationRepository),
          ),
        ],
        child: MaterialApp(
          title: 'ALU Hub',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: AppConstants.fontFamily,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppConstants.primaryColor,
              primary: AppConstants.primaryColor,
              secondary: AppConstants.secondaryColor,
              surface: AppConstants.cardColor,
              error: AppConstants.errorColor,
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: AppConstants.backgroundColor,
            cardTheme: const CardThemeData(
              color: AppConstants.cardColor,
              elevation: 2.0,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: AppConstants.cardColor,
              foregroundColor: AppConstants.textPrimaryColor,
              elevation: 0.0,
            ),
          ),
          home: const AuthGate(),
        ),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            backgroundColor: AppConstants.backgroundColor,
            body: Center(
              child: CircularProgressIndicator(
                color: AppConstants.secondaryColor,
              ),
            ),
          );
        }

        if (state is AuthAuthenticatedStudent) {
          return StudentDashboard(studentProfile: state.student);
        }

        if (state is AuthAuthenticatedStartup) {
          return StartupDashboard(startupProfile: state.startup);
        }

        if (state is AuthUnverifiedStartup) {
          return const VerificationPendingScreen();
        }

        // unauthenticated
        return const LoginScreen();
      },
    );
  }
}
