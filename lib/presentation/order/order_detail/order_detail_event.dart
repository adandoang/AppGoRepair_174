part of 'order_detail_bloc.dart';

abstract class OrderDetailEvent {}

class FetchOrderDetail extends OrderDetailEvent {
  final int orderId;

  FetchOrderDetail({required this.orderId});
}

class UploadPaymentProof extends OrderDetailEvent {
  final int orderId;
  final File imageFile;

  UploadPaymentProof({required this.orderId, required this.imageFile});
}

class AddRating extends OrderDetailEvent {
  final int orderId;
  final int rating;
  final String? comment;

  AddRating({required this.orderId, required this.rating, this.comment});
}