part of 'technician_job_bloc.dart';

abstract class TechnicianJobState {}

class TechnicianJobInitial extends TechnicianJobState {}

class TechnicianJobLoading extends TechnicianJobState {}

class TechnicianJobLoaded extends TechnicianJobState {
  final List<OrderModel> jobs;
  TechnicianJobLoaded({required this.jobs});
}

class TechnicianJobError extends TechnicianJobState {
  final String message;
  TechnicianJobError({required this.message});
}