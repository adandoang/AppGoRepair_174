import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repository/order_repository.dart';
import 'dart:io';

part 'order_detail_event.dart';
part 'order_detail_state.dart';

class OrderDetailBloc extends Bloc<OrderDetailEvent, OrderDetailState> {
  final OrderRepository orderRepository;

  OrderDetailBloc({required this.orderRepository}) : super(OrderDetailInitial()) {
    on<FetchOrderDetail>((event, emit) async {
      emit(OrderDetailLoading());
      try {
        final order = await orderRepository.getOrderDetail(event.orderId);
        emit(OrderDetailLoaded(order: order));
      } catch (e) {
        emit(OrderDetailError(message: e.toString()));
      }
    });

    on<UploadPaymentProof>((event, emit) async {
      // Ambil state saat ini untuk mendapatkan data order
      final currentState = state;
      if (currentState is OrderDetailLoaded) {
        // Saat loading, tetap kirim data order yang lama
        emit(OrderDetailUploadLoading(order: currentState.order));
        try {
          await orderRepository.uploadPaymentProof(
            orderId: event.orderId,
            imageFile: event.imageFile,
          );
          emit(OrderDetailUploadSuccess());
          // Muat ulang data setelah berhasil upload
          add(FetchOrderDetail(orderId: event.orderId));
        } catch (e) {
          emit(OrderDetailUploadFailure(error: e.toString()));
          // Jika gagal, kembalikan ke state loaded dengan data lama
          emit(currentState);
        }
      }
    });

    on<AddRating>((event, emit) async {
      emit(OrderDetailRatingLoading());
      try {
        await orderRepository.addRating(
          orderId: event.orderId,
          rating: event.rating,
          comment: event.comment,
        );
        emit(OrderDetailRatingSuccess());
        // Muat ulang data setelah berhasil rating
        add(FetchOrderDetail(orderId: event.orderId));
      } catch (e) {
        // Cek error parsing tipe data
        if (e.toString().contains("type 'Null' is not a subtype of type") ||
            e.toString().contains("type 'int' is not a subtype of type 'Map<String, dynamic>'")) {
          // Anggap sukses, jangan munculkan error
          emit(OrderDetailRatingSuccess());
          add(FetchOrderDetail(orderId: event.orderId));
        } else {
          emit(OrderDetailRatingFailure(error: e.toString()));
        }
      }
    });
  }
}