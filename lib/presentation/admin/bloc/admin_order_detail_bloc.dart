import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/response/login_response_model.dart'; // Untuk model User
import '../../../data/repository/order_repository.dart';
import '../../../data/repository/technician_repository.dart';

part 'admin_order_detail_event.dart';
part 'admin_order_detail_state.dart';

class AdminOrderDetailBloc
    extends Bloc<AdminOrderDetailEvent, AdminOrderDetailState> {
  final OrderRepository orderRepository;
  final TechnicianRepository technicianRepository;

  AdminOrderDetailBloc({
    required this.orderRepository,
    required this.technicianRepository,
  }) : super(AdminOrderDetailInitial()) {
    on<LoadAdminOrderDetail>((event, emit) async {
      emit(AdminOrderDetailLoading());
      try {
        print('Mulai mengambil daftar teknisi...');
        final technicians = await technicianRepository.getAllTechnicians();
        print('Selesai mengambil teknisi. Jumlah: ${technicians.length}');

        print('Mulai mengambil detail order ID: ${event.orderId}...');
        final order = await orderRepository.adminGetOrderDetail(event.orderId);
        print('Selesai mengambil detail order. Status: ${order.status}');

        emit(AdminOrderDetailLoaded(order: order, technicians: technicians));

      } catch (e) {
        print('Error tertangkap di dalam BLoC: $e');
        emit(AdminOrderDetailError(message: e.toString()));
      }
    });

    on<UpdateAdminOrder>((event, emit) async {
      final currentState = state;
      if (currentState is AdminOrderDetailLoaded) {
        emit(AdminOrderUpdateLoading());
        try {
          final updatedOrder = await orderRepository.adminUpdateOrder(
            orderId: event.orderId,
            status: event.status,
            technicianId: event.technicianId,
          );

          // Setelah sukses, emit state Loaded dengan data baru
          emit(AdminOrderDetailLoaded(
            order: updatedOrder,
            technicians: currentState.technicians,
          ));

          // Kirim sinyal sukses (tanpa UI)
          emit(AdminOrderUpdateSuccess(message: 'Order berhasil diperbarui'));

        } catch (e) {
          // Kirim sinyal gagal (tanpa UI)
          emit(AdminOrderUpdateFailure(error: e.toString()));
          // Kembalikan ke state loaded sebelumnya jika gagal
          emit(currentState);
        }
      }
    });

    on<ValidatePaymentButtonPressed>((event, emit) async {
      emit(PaymentValidationLoading());
      try {
        await orderRepository.validatePayment(event.orderId);
        emit(PaymentValidationSuccess());
        // Muat ulang data untuk melihat perubahan status validasi
        add(LoadAdminOrderDetail(orderId: event.orderId));
      } catch (e) {
        emit(PaymentValidationFailure(error: e.toString()));
      }
    });
  }
}