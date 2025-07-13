import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/request/create_order_request_model.dart';
import '../../../data/repository/order_repository.dart';

part 'create_order_event.dart';
part 'create_order_state.dart';

class CreateOrderBloc extends Bloc<CreateOrderEvent, CreateOrderState> {
  final OrderRepository orderRepository;

  CreateOrderBloc({required this.orderRepository}) : super(CreateOrderInitial()) {
    on<SubmitOrderButtonPressed>((event, emit) async {
      emit(CreateOrderLoading());
      try {
        final requestModel = CreateOrderRequestModel(
          categoryId: event.categoryId,
          description: event.description,
          address: event.address,
          latitude: event.latitude,
          longitude: event.longitude,
        );

        await orderRepository.createOrder(requestModel, event.imageFile);

        emit(CreateOrderSuccess());
        
      } catch (e) {
        emit(CreateOrderFailure(error: e.toString()));
      }
    });
  }
}