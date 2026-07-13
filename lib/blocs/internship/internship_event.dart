import 'package:equatable/equatable.dart';
import '../../models/internship_model.dart';

abstract class InternshipEvent extends Equatable {
  const InternshipEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllInternships extends InternshipEvent {}

class LoadStartupInternships extends InternshipEvent {
  final String startupId;

  const LoadStartupInternships(this.startupId);

  @override
  List<Object> get props => [startupId];
}

class CreateInternship extends InternshipEvent {
  final InternshipModel internship;

  const CreateInternship(this.internship);

  @override
  List<Object> get props => [internship];
}

class UpdateInternship extends InternshipEvent {
  final InternshipModel internship;

  const UpdateInternship(this.internship);

  @override
  List<Object> get props => [internship];
}

class DeleteInternship extends InternshipEvent {
  final String internshipId;

  const DeleteInternship(this.internshipId);

  @override
  List<Object> get props => [internshipId];
}

class ToggleInternshipActiveStatus extends InternshipEvent {
  final String internshipId;
  final bool isActive;

  const ToggleInternshipActiveStatus(this.internshipId, this.isActive);

  @override
  List<Object> get props => [internshipId, isActive];
}

class InternshipsListUpdated extends InternshipEvent {
  final List<InternshipModel> internships;

  const InternshipsListUpdated(this.internships);

  @override
  List<Object> get props => [internships];
}

class StartupInternshipsListUpdated extends InternshipEvent {
  final List<InternshipModel> internships;

  const StartupInternshipsListUpdated(this.internships);

  @override
  List<Object> get props => [internships];
}
