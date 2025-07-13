part of 'order_bloc.dart';

abstract class OrderEvent {}

// Event untuk mengambil daftar order pelanggan
class FetchCustomerOrders extends OrderEvent {}
class CancelOrder extends OrderEvent {
  final int orderId;
  CancelOrder({required this.orderId});
}