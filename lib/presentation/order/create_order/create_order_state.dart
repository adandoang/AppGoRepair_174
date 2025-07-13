part of 'create_order_bloc.dart';

abstract class CreateOrderState {}

class CreateOrderInitial extends CreateOrderState {}

class CreateOrderLoading extends CreateOrderState {}

class CreateOrderSuccess extends CreateOrderState {}

class CreateOrderFailure extends CreateOrderState {
  final String error;
  CreateOrderFailure({required this.error});
}