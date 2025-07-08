import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/request/login_request_model.dart';
import '../../../data/repository/auth_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;

  LoginBloc({required this.authRepository}) : super(LoginInitial()) {
    on<LoginButtonPressed>((event, emit) async {
      // 1. Keluarkan state loading saat event diterima
      emit(LoginLoading());

      try {
        // 2. Buat request model dari data event
        final requestModel = LoginRequestModel(
          email: event.email,
          password: event.password,
        );
        
        // 3. Panggil repository untuk login
        await authRepository.login(requestModel);
        
        // 4. Jika berhasil, keluarkan state success
        emit(LoginSuccess());

      } catch (e) {
        // 5. Jika gagal, keluarkan state failure dengan pesan errornya
        emit(LoginFailure(error: e.toString()));
      }
    });
  }
}