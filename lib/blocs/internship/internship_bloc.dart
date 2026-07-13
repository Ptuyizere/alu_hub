import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/internship_repository.dart';
import 'internship_event.dart';
import 'internship_state.dart';

class InternshipBloc extends Bloc<InternshipEvent, InternshipState> {
  final InternshipRepository _internshipRepository;
  StreamSubscription? _internshipSubscription;

  InternshipBloc({required InternshipRepository internshipRepository})
      : _internshipRepository = internshipRepository,
        super(InternshipInitial()) {
    on<LoadAllInternships>(_onLoadAllInternships);
    on<LoadStartupInternships>(_onLoadStartupInternships);
    on<CreateInternship>(_onCreateInternship);
    on<UpdateInternship>(_onUpdateInternship);
    on<DeleteInternship>(_onDeleteInternship);
    on<ToggleInternshipActiveStatus>(_onToggleInternshipActiveStatus);
    on<InternshipsListUpdated>(_onInternshipsListUpdated);
    on<StartupInternshipsListUpdated>(_onStartupInternshipsListUpdated);
  }

  void _onLoadAllInternships(
    LoadAllInternships event,
    Emitter<InternshipState> emit,
  ) {
    emit(InternshipLoading());
    _internshipSubscription?.cancel();
    _internshipSubscription = _internshipRepository
        .getActiveInternships()
        .listen((internships) {
      add(InternshipsListUpdated(internships));
    });
  }

  void _onLoadStartupInternships(
    LoadStartupInternships event,
    Emitter<InternshipState> emit,
  ) {
    emit(InternshipLoading());
    _internshipSubscription?.cancel();
    _internshipSubscription = _internshipRepository
        .getStartupInternships(event.startupId)
        .listen((internships) {
      add(StartupInternshipsListUpdated(internships));
    });
  }

  Future<void> _onCreateInternship(
    CreateInternship event,
    Emitter<InternshipState> emit,
  ) async {
    emit(InternshipLoading());
    try {
      await _internshipRepository.createInternship(event.internship);
      emit(InternshipOperationSuccess());
    } catch (e) {
      emit(InternshipFailure(e.toString()));
    }
  }

  Future<void> _onUpdateInternship(
    UpdateInternship event,
    Emitter<InternshipState> emit,
  ) async {
    emit(InternshipLoading());
    try {
      await _internshipRepository.updateInternship(event.internship);
      emit(InternshipOperationSuccess());
    } catch (e) {
      emit(InternshipFailure(e.toString()));
    }
  }

  Future<void> _onDeleteInternship(
    DeleteInternship event,
    Emitter<InternshipState> emit,
  ) async {
    emit(InternshipLoading());
    try {
      await _internshipRepository.deleteInternship(event.internshipId);
      emit(InternshipOperationSuccess());
    } catch (e) {
      emit(InternshipFailure(e.toString()));
    }
  }

  Future<void> _onToggleInternshipActiveStatus(
    ToggleInternshipActiveStatus event,
    Emitter<InternshipState> emit,
  ) async {
    try {
      await _internshipRepository.toggleInternshipActiveStatus(
        event.internshipId,
        event.isActive,
      );
    } catch (e) {
      emit(InternshipFailure(e.toString()));
    }
  }

  void _onInternshipsListUpdated(
    InternshipsListUpdated event,
    Emitter<InternshipState> emit,
  ) {
    emit(AllInternshipsLoaded(event.internships));
  }

  void _onStartupInternshipsListUpdated(
    StartupInternshipsListUpdated event,
    Emitter<InternshipState> emit,
  ) {
    emit(StartupInternshipsLoaded(event.internships));
  }

  @override
  Future<void> close() {
    _internshipSubscription?.cancel();
    return super.close();
  }
}
