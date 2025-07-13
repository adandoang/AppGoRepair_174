import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repository/order_repository.dart';

part 'technician_job_event.dart';
part 'technician_job_state.dart';

class TechnicianJobBloc extends Bloc<TechnicianJobEvent, TechnicianJobState> {
  final OrderRepository orderRepository;

  TechnicianJobBloc({required this.orderRepository}) : super(TechnicianJobInitial()) {
    on<FetchTechnicianJobs>((event, emit) async {
      emit(TechnicianJobLoading());
      try {
        final jobs = await orderRepository.getTechnicianJobs();
        emit(TechnicianJobLoaded(jobs: jobs));
      } catch (e) {
        emit(TechnicianJobError(message: e.toString()));
      }
    });
  }
}