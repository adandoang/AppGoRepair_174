part of 'order_bloc.dart';

abstract class OrderEvent {}

// Event untuk mengambil daftar order pelanggan
class FetchCustomerOrders extends OrderEvent {}