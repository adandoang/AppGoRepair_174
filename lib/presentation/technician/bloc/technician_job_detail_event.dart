part of 'technician_job_detail_bloc.dart';

abstract class TechnicianJobDetailEvent {}

class LoadTechnicianJobDetail extends TechnicianJobDetailEvent {
  final int orderId;
  LoadTechnicianJobDetail({required this.orderId});
}

class UpdateJobStatusByTechnician extends TechnicianJobDetailEvent {
  final int orderId;
  final String status;
  UpdateJobStatusByTechnician({required this.orderId, required this.status});
}

class AddTechnicianNotes extends TechnicianJobDetailEvent {
  final int orderId;
  final String notes;
  AddTechnicianNotes({required this.orderId, required this.notes});
}