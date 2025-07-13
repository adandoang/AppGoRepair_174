part of 'order_detail_bloc.dart';

abstract class OrderDetailState {}

class OrderDetailInitial extends OrderDetailState {}
class OrderDetailLoading extends OrderDetailState {}

class OrderDetailLoaded extends OrderDetailState {
  final OrderModel order;
  OrderDetailLoaded({required this.order});
}

class OrderDetailError extends OrderDetailState {
  final String message;
  OrderDetailError({required this.message});
}

// --- UBAH STATE INI ---
class OrderDetailUploadLoading extends OrderDetailState {
  // Sekarang ia juga membawa data order
  final OrderModel order;
  OrderDetailUploadLoading({required this.order});
}

class OrderDetailUploadSuccess extends OrderDetailState {}
class OrderDetailUploadFailure extends OrderDetailState {
  final String error;
  OrderDetailUploadFailure({required this.error});
}

// States for rating
class OrderDetailRatingLoading extends OrderDetailState {}

class OrderDetailRatingSuccess extends OrderDetailState {}

class OrderDetailRatingFailure extends OrderDetailState {
  final String error;
  OrderDetailRatingFailure({required this.error});
}