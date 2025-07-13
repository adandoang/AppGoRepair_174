import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/request/login_request_model.dart';
import '../../../data/repository/auth_repository.dart';
import '../../../data/models/response/login_response_model.dart'; 
part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;

  LoginBloc({required this.authRepository}) : super(LoginInitial()) {
    on<LoginButtonPressed>((event, emit) async {
      emit(LoginLoading());
      try {
        final requestModel = LoginRequestModel(
          email: event.email,
          password: event.password,
        );

        final response = await authRepository.login(requestModel);

        emit(LoginSuccess(user: response.user));
        
      } catch (e) {
        emit(LoginFailure(error: e.toString()));
      }
    });
  }
}