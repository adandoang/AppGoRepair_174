import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repository/order_repository.dart';

part 'technician_job_detail_event.dart';
part 'technician_job_detail_state.dart';

class TechnicianJobDetailBloc
    extends Bloc<TechnicianJobDetailEvent, TechnicianJobDetailState> {
  final OrderRepository orderRepository;

  TechnicianJobDetailBloc({required this.orderRepository})
      : super(TechnicianJobDetailInitial()) {
    on<LoadTechnicianJobDetail>((event, emit) async {
      emit(TechnicianJobDetailLoading());
      try {
        final job = await orderRepository.technicianGetJobDetail(event.orderId);
        emit(TechnicianJobDetailLoaded(job: job));
      } catch (e) {
        emit(TechnicianJobDetailError(message: e.toString()));
      }
    });

    on<UpdateJobStatusByTechnician>((event, emit) async {
      emit(TechnicianJobUpdateLoading());
      try {
        await orderRepository.technicianUpdateStatus(
          orderId: event.orderId,
          status: event.status,
        );
        // Kirim status baru ke UI
        emit(TechnicianJobUpdateSuccess(newStatus: event.status));
        // Muat ulang data setelah berhasil update
        add(LoadTechnicianJobDetail(orderId: event.orderId));
      } catch (e) {
        emit(TechnicianJobUpdateFailure(error: e.toString()));
      }
    });

    on<AddTechnicianNotes>((event, emit) async {
      emit(TechnicianNotesLoading());
      try {
        await orderRepository.addTechnicianNotes(
          orderId: event.orderId,
          notes: event.notes,
        );
        emit(TechnicianNotesSuccess());
        // Muat ulang data setelah berhasil tambah catatan
        add(LoadTechnicianJobDetail(orderId: event.orderId));
      } catch (e) {
        emit(TechnicianNotesFailure(error: e.toString()));
      }
    });
  }
}
