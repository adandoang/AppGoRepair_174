part of 'admin_order_bloc.dart';

abstract class AdminOrderState {}

class AdminOrderInitial extends AdminOrderState {}
class AdminOrderLoading extends AdminOrderState {}

class AdminOrderLoaded extends AdminOrderState {
  final List<OrderModel> orders;
  final List<CategoryModel> categories; // Sekarang state membawa data kategori

  AdminOrderLoaded({required this.orders, required this.categories});
}

class AdminOrderError extends AdminOrderState {
  final String message;
  AdminOrderError({required this.message});
}