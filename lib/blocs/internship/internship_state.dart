import 'package:equatable/equatable.dart';
import '../../models/internship_model.dart';

abstract class InternshipState extends Equatable {
  const InternshipState();

  @override
  List<Object?> get props => [];
}

class InternshipInitial extends InternshipState {}

class InternshipLoading extends InternshipState {}

class AllInternshipsLoaded extends InternshipState {
  final List<InternshipModel> internships;

  const AllInternshipsLoaded(this.internships);

  @override
  List<Object> get props => [internships];
}

class StartupInternshipsLoaded extends InternshipState {
  final List<InternshipModel> internships;

  const StartupInternshipsLoaded(this.internships);

  @override
  List<Object> get props => [internships];
}

class InternshipOperationSuccess extends InternshipState {}

class InternshipFailure extends InternshipState {
  final String errorMessage;

  const InternshipFailure(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
