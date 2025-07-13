part of 'register_bloc.dart';

abstract class RegisterState {}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

// State saat registrasi berhasil
class RegisterSuccess extends RegisterState {}

// State saat registrasi gagal
class RegisterFailure extends RegisterState {
  final String error;
  RegisterFailure({required this.error});
}