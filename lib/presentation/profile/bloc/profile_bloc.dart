import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/request/update_profile_request_model.dart';
import '../../../data/models/response/login_response_model.dart';
import '../../../data/repository/auth_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthRepository authRepository;

  ProfileBloc({required this.authRepository}) : super(ProfileInitial()) {
    on<LoadProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        final user = await authRepository.getCurrentUser();
        emit(ProfileLoaded(user: user));
      } catch (e) {
        emit(ProfileUpdateFailure(error: e.toString()));
      }
    });

    on<UpdateProfileButtonPressed>((event, emit) async {
      emit(ProfileLoading());
      try {
        await authRepository.updateProfile(event.data);
        emit(ProfileUpdateSuccess());
        // Muat ulang data profil setelah berhasil update
        add(LoadProfile());
      } catch (e) {
        emit(ProfileUpdateFailure(error: e.toString()));
      }
    });
  }
}