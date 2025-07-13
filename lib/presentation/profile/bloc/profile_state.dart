part of 'profile_bloc.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileLoaded extends ProfileState {
  final User user;
  ProfileLoaded({required this.user});
}
class ProfileUpdateSuccess extends ProfileState {}
class ProfileUpdateFailure extends ProfileState {
  final String error;
  ProfileUpdateFailure({required this.error});
}