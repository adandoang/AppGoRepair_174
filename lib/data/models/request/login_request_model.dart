class LoginRequestModel {
  final String email;
  final String password;

  LoginRequestModel({
    required this.email,
    required this.password,
  });

  // Mengubah objek Dart menjadi format JSON untuk dikirim ke API
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}