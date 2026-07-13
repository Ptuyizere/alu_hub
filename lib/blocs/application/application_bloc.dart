import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/application_repository.dart';
import 'application_event.dart';
import 'application_state.dart';

class ApplicationBloc extends Bloc<ApplicationEvent, ApplicationState> {
  final ApplicationRepository _applicationRepository;
  StreamSubscription? _applicationSubscription;

  ApplicationBloc({required ApplicationRepository applicationRepository})
      : _applicationRepository = applicationRepository,
        super(ApplicationInitial()) {
    on<LoadStudentApplications>(_onLoadStudentApplications);
    on<LoadStartupApplications>(_onLoadStartupApplications);
    on<SubmitApplication>(_onSubmitApplication);
    on<UpdateApplicationStatusEvent>(_onUpdateApplicationStatus);
    on<StudentApplicationsListUpdated>(_onStudentApplicationsListUpdated);
    on<StartupApplicationsListUpdated>(_onStartupApplicationsListUpdated);
  }

  void _onLoadStudentApplications(
    LoadStudentApplications event,
    Emitter<ApplicationState> emit,
  ) {
    emit(ApplicationLoading());
    _applicationSubscription?.cancel();
    _applicationSubscription = _applicationRepository
        .getStudentApplications(event.studentId)
        .listen((apps) {
      add(StudentApplicationsListUpdated(apps));
    });
  }

  void _onLoadStartupApplications(
    LoadStartupApplications event,
    Emitter<ApplicationState> emit,
  ) {
    emit(ApplicationLoading());
    _applicationSubscription?.cancel();
    _applicationSubscription = _applicationRepository
        .getStartupApplications(event.startupId)
        .listen((apps) {
      add(StartupApplicationsListUpdated(apps));
    });
  }

  Future<void> _onSubmitApplication(
    SubmitApplication event,
    Emitter<ApplicationState> emit,
  ) async {
    emit(ApplicationLoading());
    try {
      await _applicationRepository.submitApplication(event.application);
      emit(ApplicationOperationSuccess());
    } catch (e) {
      emit(ApplicationFailure(e.toString()));
    }
  }

  Future<void> _onUpdateApplicationStatus(
    UpdateApplicationStatusEvent event,
    Emitter<ApplicationState> emit,
  ) async {
    try {
      await _applicationRepository.updateApplicationStatus(
        applicationId: event.applicationId,
        status: event.status,
        startupInfo: event.startupInfo,
      );
      // Status update triggers repository changes
    } catch (e) {
      emit(ApplicationFailure(e.toString()));
    }
  }

  void _onStudentApplicationsListUpdated(
    StudentApplicationsListUpdated event,
    Emitter<ApplicationState> emit,
  ) {
    emit(StudentApplicationsLoaded(event.applications));
  }

  void _onStartupApplicationsListUpdated(
    StartupApplicationsListUpdated event,
    Emitter<ApplicationState> emit,
  ) {
    emit(StartupApplicationsLoaded(event.applications));
  }

  @override
  Future<void> close() {
    _applicationSubscription?.cancel();
    return super.close();
  }
}
