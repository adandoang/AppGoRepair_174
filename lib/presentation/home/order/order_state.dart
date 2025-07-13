part of 'order_bloc.dart';

abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

// State saat data berhasil dimuat, membawa daftar order
class OrderLoaded extends OrderState {
  final List<OrderModel> orders;
  OrderLoaded({required this.orders});
}

// State saat terjadi error
class OrderError extends OrderState {
  final String message;
  OrderError({required this.message});
}