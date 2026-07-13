import 'package:equatable/equatable.dart';
import '../../models/application_model.dart';

abstract class ApplicationState extends Equatable {
  const ApplicationState();

  @override
  List<Object?> get props => [];
}

class ApplicationInitial extends ApplicationState {}

class ApplicationLoading extends ApplicationState {}

class StudentApplicationsLoaded extends ApplicationState {
  final List<ApplicationModel> applications;

  const StudentApplicationsLoaded(this.applications);

  @override
  List<Object> get props => [applications];
}

class StartupApplicationsLoaded extends ApplicationState {
  final List<ApplicationModel> applications;

  const StartupApplicationsLoaded(this.applications);

  @override
  List<Object> get props => [applications];
}

class ApplicationOperationSuccess extends ApplicationState {}

class ApplicationFailure extends ApplicationState {
  final String errorMessage;

  const ApplicationFailure(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
