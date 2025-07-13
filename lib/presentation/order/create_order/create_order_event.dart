part of 'create_order_bloc.dart';

abstract class CreateOrderEvent {}

class SubmitOrderButtonPressed extends CreateOrderEvent {
  final int categoryId;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final File imageFile;

  SubmitOrderButtonPressed({
    required this.categoryId,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.imageFile,
  });
}