// lib/presentation/home/bloc/order_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repository/order_repository.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository;

  OrderBloc({required this.orderRepository}) : super(OrderInitial()) {
    // Tangani event FetchCustomerOrders
    on<FetchCustomerOrders>((event, emit) async {
      emit(OrderLoading());
      try {
        final orders = await orderRepository.getCustomerOrders();
        emit(OrderLoaded(orders: orders));
      } catch (e) {
        emit(OrderError(message: e.toString()));
      }
    });

    on<CancelOrder>((event, emit) async {
      try {
        await orderRepository.cancelOrder(event.orderId);
        // Setelah berhasil, langsung panggil event untuk refresh daftar
        add(FetchCustomerOrders());
      } catch (e) {
        // TODO: Tampilkan error ke UI jika perlu
        print(e.toString());
      }
    });
  }
}