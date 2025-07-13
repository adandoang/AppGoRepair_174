part of 'technician_job_detail_bloc.dart';

abstract class TechnicianJobDetailState {}

class TechnicianJobDetailInitial extends TechnicianJobDetailState {}

class TechnicianJobDetailLoading extends TechnicianJobDetailState {}

class TechnicianJobDetailLoaded extends TechnicianJobDetailState {
  final OrderModel job;
  TechnicianJobDetailLoaded({required this.job});
}

class TechnicianJobDetailError extends TechnicianJobDetailState {
  final String message;
  TechnicianJobDetailError({required this.message});
}

// States for update process
class TechnicianJobUpdateLoading extends TechnicianJobDetailState {}

class TechnicianJobUpdateSuccess extends TechnicianJobDetailState {
  // Tambahkan properti ini untuk mengetahui status baru
  final String newStatus;
  TechnicianJobUpdateSuccess({required this.newStatus});
}

class TechnicianJobUpdateFailure extends TechnicianJobDetailState {
  final String error;
  TechnicianJobUpdateFailure({required this.error});
}

// States for technician notes
class TechnicianNotesLoading extends TechnicianJobDetailState {}

class TechnicianNotesSuccess extends TechnicianJobDetailState {}

class TechnicianNotesFailure extends TechnicianJobDetailState {
  final String error;
  TechnicianNotesFailure({required this.error});
}
