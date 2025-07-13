part of 'register_bloc.dart';

abstract class RegisterEvent {}

class RegisterButtonPressed extends RegisterEvent {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String phoneNumber;

  RegisterButtonPressed({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.phoneNumber,
  });
}