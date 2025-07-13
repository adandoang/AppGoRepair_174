class UpdateProfileRequestModel {
  final String name;
  final String email;
  final String phoneNumber;
  final String? password;
  final String? passwordConfirmation;

  UpdateProfileRequestModel({
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.password,
    this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
    };
    if (password != null && password!.isNotEmpty) {
      data['password'] = password;
      data['password_confirmation'] = passwordConfirmation;
    }
    return data;
  }
}