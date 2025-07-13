import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/request/register_request_model.dart';
import '../../../data/repository/auth_repository.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository authRepository;

  RegisterBloc({required this.authRepository}) : super(RegisterInitial()) {
    on<RegisterButtonPressed>((event, emit) async {
      emit(RegisterLoading());
      try {
        final requestModel = RegisterRequestModel(
          name: event.name,
          email: event.email,
          password: event.password,
          passwordConfirmation: event.passwordConfirmation,
          phoneNumber: event.phoneNumber,
        );
        
        await authRepository.register(requestModel);
        emit(RegisterSuccess());

      } catch (e) {
        emit(RegisterFailure(error: e.toString()));
      }
    });
  }
}