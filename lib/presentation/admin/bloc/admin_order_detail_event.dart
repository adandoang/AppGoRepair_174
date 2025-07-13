part of 'admin_order_detail_bloc.dart';

abstract class AdminOrderDetailEvent {}

// Event untuk memuat semua data yang dibutuhkan halaman detail
class LoadAdminOrderDetail extends AdminOrderDetailEvent {
  final int orderId;
  LoadAdminOrderDetail({required this.orderId});
}

class UpdateAdminOrder extends AdminOrderDetailEvent {
  final int orderId;
  final String status;
  final int? technicianId;

  UpdateAdminOrder({
    required this.orderId,
    required this.status,
    this.technicianId,
  });
}

class ValidatePaymentButtonPressed extends AdminOrderDetailEvent {
  final int orderId;
  ValidatePaymentButtonPressed({required this.orderId});
}