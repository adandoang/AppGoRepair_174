part of 'admin_order_detail_bloc.dart';

abstract class AdminOrderDetailState {}

class AdminOrderDetailInitial extends AdminOrderDetailState {}

class AdminOrderDetailLoading extends AdminOrderDetailState {}

// State saat semua data berhasil dimuat
class AdminOrderDetailLoaded extends AdminOrderDetailState {
  final OrderModel order;
  final List<User> technicians;

  AdminOrderDetailLoaded({required this.order, required this.technicians});
}

class AdminOrderDetailError extends AdminOrderDetailState {
  final String message;
  AdminOrderDetailError({required this.message});
}

// Tambahkan state-state baru
class AdminOrderUpdateLoading extends AdminOrderDetailState {}

class AdminOrderUpdateSuccess extends AdminOrderDetailState {
    final String message;
    AdminOrderUpdateSuccess({required this.message});
}

class AdminOrderUpdateFailure extends AdminOrderDetailState {
  final String error;
  AdminOrderUpdateFailure({required this.error});
}

// Tambahkan state-state baru
class PaymentValidationLoading extends AdminOrderDetailState {}
class PaymentValidationSuccess extends AdminOrderDetailState {}
class PaymentValidationFailure extends AdminOrderDetailState {
  final String error;
  PaymentValidationFailure({required this.error});
}