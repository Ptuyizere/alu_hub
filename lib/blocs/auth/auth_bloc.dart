import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription? _authSubscription;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthStudentRegisterRequested>(_onAuthStudentRegisterRequested);
    on<AuthStartupRegisterRequested>(_onAuthStartupRegisterRequested);
    on<AuthCheckVerificationStatus>(_onAuthCheckVerificationStatus);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);

    // Set up real-time listener for Auth changes
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      if (user == null) {
        add(AuthSignOutRequested());
      } else {
        add(AuthCheckRequested());
      }
    });
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final uid = _authRepository.currentUid;
    if (uid == null) {
      emit(AuthUnauthenticated());
      return;
    }

    try {
      final role = await _authRepository.getUserRole(uid);
      if (role == 'student') {
        final student = await _authRepository.getStudentProfile(uid);
        emit(AuthAuthenticatedStudent(student));
      } else if (role == 'startup') {
        final startup = await _authRepository.getStartupProfile(uid);
        if (startup.isVerified) {
          emit(AuthAuthenticatedStartup(startup));
        } else {
          emit(AuthUnverifiedStartup(startup));
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final credential = await _authRepository.signIn(event.email, event.password);
      final uid = credential.user!.uid;
      final role = await _authRepository.getUserRole(uid);
      
      if (role == 'student') {
        final student = await _authRepository.getStudentProfile(uid);
        emit(AuthAuthenticatedStudent(student));
      } else if (role == 'startup') {
        final startup = await _authRepository.getStartupProfile(uid);
        if (startup.isVerified) {
          emit(AuthAuthenticatedStartup(startup));
        } else {
          emit(AuthUnverifiedStartup(startup));
        }
      } else {
        emit(AuthFailure('Invalid user role. Contact Admin.'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAuthStudentRegisterRequested(
    AuthStudentRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.registerStudent(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        academicProgram: event.academicProgram,
        bio: event.bio,
        skills: event.skills,
        phoneNumber: event.phoneNumber,
      );
      final uid = _authRepository.currentUid;
      if (uid != null) {
        final student = await _authRepository.getStudentProfile(uid);
        emit(AuthAuthenticatedStudent(student));
      } else {
        emit(AuthFailure('Registration failed: UID is null.'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAuthStartupRegisterRequested(
    AuthStartupRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.registerStartup(
        email: event.email,
        password: event.password,
        companyName: event.companyName,
        description: event.description,
        website: event.website,
        industry: event.industry,
        filePath: event.filePath,
        fileBytes: event.fileBytes,
        phoneNumber: event.phoneNumber,
      );
      final uid = _authRepository.currentUid;
      if (uid != null) {
        final startup = await _authRepository.getStartupProfile(uid);
        emit(AuthUnverifiedStartup(startup));
      } else {
        emit(AuthFailure('Registration failed: UID is null.'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAuthCheckVerificationStatus(
    AuthCheckVerificationStatus event,
    Emitter<AuthState> emit,
  ) async {
    final uid = _authRepository.currentUid;
    if (uid == null) {
      emit(AuthUnauthenticated());
      return;
    }

    try {
      final startup = await _authRepository.getStartupProfile(uid);
      if (startup.isVerified) {
        emit(AuthAuthenticatedStartup(startup));
      } else {
        emit(AuthUnverifiedStartup(startup));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
