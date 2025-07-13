class RegisterRequestModel {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String phoneNumber;

  RegisterRequestModel({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'phone_number': phoneNumber,
    };
  }
}