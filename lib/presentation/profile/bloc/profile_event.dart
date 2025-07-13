part of 'profile_bloc.dart';

abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {}

class UpdateProfileButtonPressed extends ProfileEvent {
  final UpdateProfileRequestModel data;
  UpdateProfileButtonPressed({required this.data});
}