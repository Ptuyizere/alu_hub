import 'package:equatable/equatable.dart';
import '../../models/application_model.dart';
import '../../models/user_model.dart';

abstract class ApplicationEvent extends Equatable {
  const ApplicationEvent();

  @override
  List<Object?> get props => [];
}

class LoadStudentApplications extends ApplicationEvent {
  final String studentId;

  const LoadStudentApplications(this.studentId);

  @override
  List<Object> get props => [studentId];
}

class LoadStartupApplications extends ApplicationEvent {
  final String startupId;

  const LoadStartupApplications(this.startupId);

  @override
  List<Object> get props => [startupId];
}

class SubmitApplication extends ApplicationEvent {
  final ApplicationModel application;

  const SubmitApplication(this.application);

  @override
  List<Object> get props => [application];
}

class UpdateApplicationStatusEvent extends ApplicationEvent {
  final String applicationId;
  final String status;
  final StartupProfile startupInfo;

  const UpdateApplicationStatusEvent({
    required this.applicationId,
    required this.status,
    required this.startupInfo,
  });

  @override
  List<Object> get props => [applicationId, status, startupInfo];
}

class StudentApplicationsListUpdated extends ApplicationEvent {
  final List<ApplicationModel> applications;

  const StudentApplicationsListUpdated(this.applications);

  @override
  List<Object> get props => [applications];
}

class StartupApplicationsListUpdated extends ApplicationEvent {
  final List<ApplicationModel> applications;

  const StartupApplicationsListUpdated(this.applications);

  @override
  List<Object> get props => [applications];
}
